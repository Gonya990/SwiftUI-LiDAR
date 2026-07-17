//
//  ARWrapperView.swift
//  Lidar Scan
//

import SwiftUI
import RealityKit
import ARKit

enum ScanExportResult: Equatable {
    case idle
    case success(fileName: String)
    case failed(message: String)
}

struct ARWrapperView: UIViewRepresentable {
    @Binding var exportTrigger: Int
    @Binding var exportFileName: String
    @Binding var exportResult: ScanExportResult
    @Binding var pauseSession: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(
            exportTrigger: $exportTrigger,
            exportFileName: $exportFileName,
            exportResult: $exportResult,
            pauseSession: $pauseSession
        )
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false
        arView.environment.sceneUnderstanding.options = [.occlusion, .physics]
        arView.debugOptions.insert(.showSceneUnderstanding)

        context.coordinator.arView = arView
        context.coordinator.startSessionIfNeeded(on: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.handleUpdates(on: uiView)
    }

    final class Coordinator: NSObject {
        @Binding var exportTrigger: Int
        @Binding var exportFileName: String
        @Binding var exportResult: ScanExportResult
        @Binding var pauseSession: Bool

        weak var arView: ARView?
        private var sessionRunning = false
        private var lastHandledExportTrigger = 0

        init(
            exportTrigger: Binding<Int>,
            exportFileName: Binding<String>,
            exportResult: Binding<ScanExportResult>,
            pauseSession: Binding<Bool>
        ) {
            _exportTrigger = exportTrigger
            _exportFileName = exportFileName
            _exportResult = exportResult
            _pauseSession = pauseSession
        }

        func startSessionIfNeeded(on arView: ARView) {
            guard !sessionRunning else { return }
            let configuration = ARWorldTrackingConfiguration()
            configuration.environmentTexturing = .automatic
            configuration.sceneReconstruction = .meshWithClassification
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
                configuration.frameSemantics.insert(.sceneDepth)
            }
            arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            sessionRunning = true
        }

        func handleUpdates(on arView: ARView) {
            // Export first — even if alert had paused the session momentarily
            if exportTrigger != lastHandledExportTrigger {
                lastHandledExportTrigger = exportTrigger
                performExport(from: arView)
            }

            if pauseSession {
                if sessionRunning {
                    arView.session.pause()
                    sessionRunning = false
                }
                return
            }

            if !sessionRunning {
                startSessionIfNeeded(on: arView)
            }
        }

        private func performExport(from arView: ARView) {
            guard let frame = arView.session.currentFrame else {
                exportResult = .failed(message: "AR session not ready. Try again.")
                return
            }

            let meshAnchors = frame.anchors.compactMap { $0 as? ARMeshAnchor }
            guard !meshAnchors.isEmpty else {
                exportResult = .failed(message: "No 3D mesh yet. Walk slowly around the object for 30–60 sec.")
                return
            }

            let viewModel = ExportViewModel()
            guard let asset = viewModel.convertToAsset(
                meshAnchor: meshAnchors,
                camera: frame.camera
            ) else {
                exportResult = .failed(message: "Could not build 3D model.")
                return
            }

            do {
                let savedName = try viewModel.export(asset: asset, fileName: exportFileName)
                exportResult = .success(fileName: savedName)
            } catch {
                exportResult = .failed(message: error.localizedDescription)
            }
        }
    }
}

class ExportViewModel: NSObject, ObservableObject, ARSessionDelegate {
    func convertToAsset(meshAnchor: [ARMeshAnchor], camera: ARCamera) -> MDLAsset? {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        let asset = MDLAsset()
        for anchor in meshAnchor {
            let mdlMesh = anchor.geometry.toMDLMesh(device: device, camera: camera, modelMatrix: anchor.transform)
            asset.add(mdlMesh)
        }
        return asset
    }

    /// Returns the saved file name including `.obj` extension.
    @discardableResult
    func export(asset: MDLAsset, fileName: String) throws -> String {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "com.igorgoncharenko.lidarscan", code: 153,
                          userInfo: [NSLocalizedDescriptionKey: "Documents folder unavailable"])
        }
        let folderURL = directory.appendingPathComponent("OBJ_FILES")
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        let url = uniqueExportURL(in: folderURL, requestedName: fileName)
        try asset.export(to: url)
        print("Saved scan: \(url.path)")
        return url.lastPathComponent
    }

    private func uniqueExportURL(in directory: URL, requestedName: String) -> URL {
        let invalidCharacters = CharacterSet(charactersIn: "/\\:").union(.controlCharacters)
        let trimmedName = requestedName.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedName = trimmedName.unicodeScalars.map { scalar in
            invalidCharacters.contains(scalar) ? "-" : String(scalar)
        }.joined()
        let nameWithoutExtension = sanitizedName.lowercased().hasSuffix(".obj")
            ? String(sanitizedName.dropLast(4))
            : sanitizedName
        let cleanBase = nameWithoutExtension
            .trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: ".")))
        let base = String((cleanBase.isEmpty ? UUID().uuidString : cleanBase).prefix(100))

        var candidate = directory.appendingPathComponent("\(base).obj", isDirectory: false)
        var suffix = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = directory.appendingPathComponent("\(base)-\(suffix).obj", isDirectory: false)
            suffix += 1
        }
        return candidate
    }
}

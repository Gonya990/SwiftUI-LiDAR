//
//  ARWrapperView.swift
//  Lidar Scan
//

import SwiftUI
import RealityKit
import ARKit

enum ScanExportResult: Equatable {
    case idle
    case success(fileURL: URL)
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
                exportResult = .failed(message: "AR-сеанс ещё не готов. Подождите несколько секунд и повторите.")
                return
            }

            let meshAnchors = frame.anchors.compactMap { $0 as? ARMeshAnchor }
            guard !meshAnchors.isEmpty else {
                exportResult = .failed(message: "3D-сетка ещё не построена. Медленно обойдите объект в течение 30–60 секунд.")
                return
            }

            let viewModel = ExportViewModel()
            guard let asset = viewModel.convertToAsset(
                meshAnchor: meshAnchors,
                camera: frame.camera
            ) else {
                exportResult = .failed(message: "Не удалось собрать 3D-модель из LiDAR-сетки.")
                return
            }

            do {
                let savedURL = try viewModel.export(asset: asset, fileName: exportFileName)
                exportResult = .success(fileURL: savedURL)
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

    /// Returns the saved OBJ URL inside the app's Files-visible Documents folder.
    @discardableResult
    func export(asset: MDLAsset, fileName: String) throws -> URL {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "com.igorgoncharenko.lidarscan", code: 153,
                          userInfo: [NSLocalizedDescriptionKey: "Папка Documents недоступна"])
        }
        let folderURL = directory
            .appendingPathComponent("Scans", isDirectory: true)
            .appendingPathComponent("Rooms", isDirectory: true)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        let safeName = sanitizedFileName(fileName)
        let base = safeName.isEmpty ? "scan-\(Self.timestamp.string(from: Date()))" : safeName
        var finalName = base.hasSuffix(".obj") ? base : "\(base).obj"
        var url = folderURL.appendingPathComponent(finalName)
        if FileManager.default.fileExists(atPath: url.path) {
            finalName = "\(base)-\(Self.timestamp.string(from: Date())).obj"
            url = folderURL.appendingPathComponent(finalName)
        }
        guard MDLAsset.canExportFileExtension("obj") else {
            throw NSError(
                domain: "com.igorgoncharenko.lidarscan",
                code: 154,
                userInfo: [NSLocalizedDescriptionKey: "Экспорт OBJ недоступен на этом устройстве"]
            )
        }
        try asset.export(to: url)
        return url
    }

    private func sanitizedFileName(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        return trimmed.unicodeScalars
            .map { allowed.contains($0) ? Character(String($0)) : "-" }
            .reduce(into: "") { $0.append($1) }
            .replacingOccurrences(of: " ", with: "-")
    }

    private static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

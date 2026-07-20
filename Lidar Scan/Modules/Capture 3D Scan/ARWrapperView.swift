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
    @Binding var meshAnchorCount: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(
            exportTrigger: $exportTrigger,
            exportFileName: $exportFileName,
            exportResult: $exportResult,
            pauseSession: $pauseSession,
            meshAnchorCount: $meshAnchorCount
        )
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        // Occlusion/physics help RealityKit keep scene understanding alive;
        // debug mesh alone is unreliable on some iOS 18 devices — we also draw explicit mesh entities.
        arView.environment.sceneUnderstanding.options = [.occlusion, .physics]
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.renderOptions.insert(.disableMotionBlur)
        arView.renderOptions.insert(.disableDepthOfField)

        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        context.coordinator.startSessionIfNeeded(on: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.syncBindings(
            exportTrigger: $exportTrigger,
            exportFileName: $exportFileName,
            exportResult: $exportResult,
            pauseSession: $pauseSession,
            meshAnchorCount: $meshAnchorCount
        )
        context.coordinator.handleUpdates(on: uiView)
    }

    final class Coordinator: NSObject, ARSessionDelegate {
        var exportTrigger: Binding<Int>
        var exportFileName: Binding<String>
        var exportResult: Binding<ScanExportResult>
        var pauseSession: Binding<Bool>
        var meshAnchorCount: Binding<Int>

        weak var arView: ARView?
        private var sessionRunning = false
        private var lastHandledExportTrigger = 0
        private var meshEntities: [UUID: ModelEntity] = [:]
        private var meshAnchorsByID: [UUID: AnchorEntity] = [:]
        private var lastVisualUpdate = Date.distantPast
        private let visualUpdateInterval: TimeInterval = 0.2

        private lazy var meshMaterial: SimpleMaterial = {
            SimpleMaterial(
                color: UIColor(red: 0.25, green: 0.85, blue: 1.0, alpha: 0.42),
                roughness: 1.0,
                isMetallic: false
            )
        }()

        init(
            exportTrigger: Binding<Int>,
            exportFileName: Binding<String>,
            exportResult: Binding<ScanExportResult>,
            pauseSession: Binding<Bool>,
            meshAnchorCount: Binding<Int>
        ) {
            self.exportTrigger = exportTrigger
            self.exportFileName = exportFileName
            self.exportResult = exportResult
            self.pauseSession = pauseSession
            self.meshAnchorCount = meshAnchorCount
        }

        func syncBindings(
            exportTrigger: Binding<Int>,
            exportFileName: Binding<String>,
            exportResult: Binding<ScanExportResult>,
            pauseSession: Binding<Bool>,
            meshAnchorCount: Binding<Int>
        ) {
            self.exportTrigger = exportTrigger
            self.exportFileName = exportFileName
            self.exportResult = exportResult
            self.pauseSession = pauseSession
            self.meshAnchorCount = meshAnchorCount
        }

        func startSessionIfNeeded(on arView: ARView) {
            guard !sessionRunning else { return }

            guard ARWorldTrackingConfiguration.isSupported else {
                DispatchQueue.main.async {
                    self.exportResult.wrappedValue = .failed(
                        message: "World Tracking недоступен на этом устройстве."
                    )
                }
                return
            }

            let configuration = ARWorldTrackingConfiguration()
            configuration.environmentTexturing = .automatic
            configuration.planeDetection = [.horizontal, .vertical]

            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
                configuration.sceneReconstruction = .meshWithClassification
            } else if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
            } else {
                DispatchQueue.main.async {
                    self.exportResult.wrappedValue = .failed(
                        message: "LiDAR scene reconstruction недоступна на этом устройстве."
                    )
                }
                return
            }

            // sceneDepth is optional; mesh reconstruction does not depend on it.
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
                configuration.frameSemantics.insert(.sceneDepth)
            }

            arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            // Re-assert visualization after run — some iOS builds drop debug options on session start.
            arView.debugOptions.insert(.showSceneUnderstanding)
            sessionRunning = true
        }

        func handleUpdates(on arView: ARView) {
            if exportTrigger.wrappedValue != lastHandledExportTrigger {
                lastHandledExportTrigger = exportTrigger.wrappedValue
                performExport(from: arView)
            }

            if pauseSession.wrappedValue {
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

        // MARK: - ARSessionDelegate (explicit mesh visualization)

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            updateMeshVisualization(with: anchors, force: true)
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            updateMeshVisualization(with: anchors, force: false)
        }

        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            guard let arView else { return }
            for anchor in anchors {
                guard let meshAnchor = anchor as? ARMeshAnchor else { continue }
                let id = meshAnchor.identifier
                if let entityAnchor = meshAnchorsByID.removeValue(forKey: id) {
                    arView.scene.removeAnchor(entityAnchor)
                }
                meshEntities.removeValue(forKey: id)
            }
            publishMeshCount(from: session)
        }

        private func updateMeshVisualization(with anchors: [ARAnchor], force: Bool) {
            let meshAnchors = anchors.compactMap { $0 as? ARMeshAnchor }
            guard !meshAnchors.isEmpty, let arView else { return }

            let now = Date()
            if !force, now.timeIntervalSince(lastVisualUpdate) < visualUpdateInterval {
                publishMeshCount(from: arView.session)
                return
            }
            lastVisualUpdate = now

            for meshAnchor in meshAnchors {
                guard let meshResource = makeMeshResource(from: meshAnchor.geometry) else { continue }
                let id = meshAnchor.identifier

                if let model = meshEntities[id] {
                    model.model?.mesh = meshResource
                    continue
                }

                let model = ModelEntity(mesh: meshResource, materials: [meshMaterial])
                let anchorEntity = AnchorEntity(anchor: meshAnchor)
                anchorEntity.addChild(model)
                arView.scene.addAnchor(anchorEntity)
                meshEntities[id] = model
                meshAnchorsByID[id] = anchorEntity
            }

            publishMeshCount(from: arView.session)
        }

        private func publishMeshCount(from session: ARSession) {
            let count = session.currentFrame?.anchors.compactMap { $0 as? ARMeshAnchor }.count
                ?? meshEntities.count
            DispatchQueue.main.async {
                if self.meshAnchorCount.wrappedValue != count {
                    self.meshAnchorCount.wrappedValue = count
                }
            }
        }

        private func makeMeshResource(from geometry: ARMeshGeometry) -> MeshResource? {
            let vertexCount = geometry.vertices.count
            guard vertexCount > 0, geometry.faces.count > 0 else { return nil }

            var positions: [SIMD3<Float>] = []
            positions.reserveCapacity(vertexCount)
            for index in 0..<vertexCount {
                positions.append(geometry.vertex(at: UInt32(index)))
            }

            let faces = geometry.faces
            let indicesPerFace = faces.indexCountPerPrimitive
            var indices: [UInt32] = []
            indices.reserveCapacity(faces.count * indicesPerFace)

            for faceIndex in 0..<faces.count {
                for offset in 0..<indicesPerFace {
                    let byteOffset = (faceIndex * indicesPerFace + offset) * faces.bytesPerIndex
                    let pointer = faces.buffer.contents().advanced(by: byteOffset)
                    let value: UInt32
                    if faces.bytesPerIndex == 2 {
                        value = UInt32(pointer.assumingMemoryBound(to: UInt16.self).pointee)
                    } else {
                        value = pointer.assumingMemoryBound(to: UInt32.self).pointee
                    }
                    indices.append(value)
                }
            }

            var descriptor = MeshDescriptor(name: "lidar-mesh")
            descriptor.positions = MeshBuffers.Positions(positions)
            descriptor.primitives = .triangles(indices)

            do {
                return try MeshResource.generate(from: [descriptor])
            } catch {
                return nil
            }
        }

        private func performExport(from arView: ARView) {
            // Prefer a live frame; if briefly paused, still try currentFrame (anchors usually remain).
            guard let frame = arView.session.currentFrame else {
                exportResult.wrappedValue = .failed(
                    message: "AR-сеанс ещё не готов. Подождите несколько секунд и повторите."
                )
                return
            }

            let meshAnchors = frame.anchors.compactMap { $0 as? ARMeshAnchor }
            guard !meshAnchors.isEmpty else {
                exportResult.wrappedValue = .failed(
                    message: "3D-сетка ещё не построена. Медленно обойдите комнату 30–60 секунд, пока не появится голубая сетка."
                )
                return
            }

            let viewModel = ExportViewModel()
            guard let asset = viewModel.convertToAsset(
                meshAnchor: meshAnchors,
                camera: frame.camera
            ) else {
                exportResult.wrappedValue = .failed(message: "Не удалось собрать 3D-модель из LiDAR-сетки.")
                return
            }

            do {
                let savedURL = try viewModel.export(asset: asset, fileName: exportFileName.wrappedValue)
                exportResult.wrappedValue = .success(fileURL: savedURL)
            } catch {
                exportResult.wrappedValue = .failed(message: error.localizedDescription)
            }
        }
    }
}

class ExportViewModel: NSObject, ObservableObject {
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

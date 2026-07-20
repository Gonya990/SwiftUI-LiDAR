//
//  ARWrapperView.swift
//  Lidar Scan
//

import SwiftUI
import ARKit
import SceneKit
import MetalKit
import ModelIO

enum ScanExportResult: Equatable {
    case idle
    case success(fileURL: URL)
    case failed(message: String)
}

/// Room LiDAR capture with SceneKit mesh overlay.
/// RealityKit ModelEntity overlays were created (runtime entities>0) but stayed invisible —
/// stealing ARSession.delegate from ARView broke compositing. ARSCNView is the reliable path.
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

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = context.coordinator
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = SCNScene()
        // Cyan fill + wireframe helps the mesh read over the camera feed.
        sceneView.debugOptions = []

        context.coordinator.sceneView = sceneView
        context.coordinator.startSessionIfNeeded(on: sceneView)
        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.syncBindings(
            exportTrigger: $exportTrigger,
            exportFileName: $exportFileName,
            exportResult: $exportResult,
            pauseSession: $pauseSession,
            meshAnchorCount: $meshAnchorCount
        )
        context.coordinator.handleUpdates(on: uiView)
    }

    final class Coordinator: NSObject, ARSCNViewDelegate {
        var exportTrigger: Binding<Int>
        var exportFileName: Binding<String>
        var exportResult: Binding<ScanExportResult>
        var pauseSession: Binding<Bool>
        var meshAnchorCount: Binding<Int>

        weak var sceneView: ARSCNView?
        private var sessionRunning = false
        private var lastHandledExportTrigger = 0
        private var meshNodeCount = 0

        private lazy var meshMaterial: SCNMaterial = {
            let material = SCNMaterial()
            material.fillMode = .fill
            material.isDoubleSided = true
            material.diffuse.contents = UIColor(red: 0.0, green: 0.9, blue: 1.0, alpha: 0.55)
            material.emission.contents = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
            material.transparencyMode = .rgbZero
            material.lightingModel = .constant
            // Draw on top of the camera feed; depth fight was hiding the mesh.
            material.writesToDepthBuffer = false
            material.readsFromDepthBuffer = false
            return material
        }()

        private lazy var wireMaterial: SCNMaterial = {
            let material = SCNMaterial()
            material.fillMode = .lines
            material.isDoubleSided = true
            material.diffuse.contents = UIColor.cyan
            material.emission.contents = UIColor.white
            material.lightingModel = .constant
            material.writesToDepthBuffer = false
            material.readsFromDepthBuffer = false
            return material
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

        func startSessionIfNeeded(on sceneView: ARSCNView) {
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
            // Gravity keeps Y up in meters via IMU (gyro+accel). Heading also locks to magnetic north.
            configuration.worldAlignment = .gravityAndHeading
            // ARKit units are meters; scene reconstruction already fuses LiDAR depth + visual + IMU.

            let supportsClassified = ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification)
            let supportsMesh = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
            if supportsClassified {
                configuration.sceneReconstruction = .meshWithClassification
            } else if supportsMesh {
                configuration.sceneReconstruction = .mesh
            } else {
                DispatchQueue.main.async {
                    self.exportResult.wrappedValue = .failed(
                        message: "LiDAR scene reconstruction недоступна на этом устройстве."
                    )
                }
                return
            }

            if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
                configuration.frameSemantics.insert(.sceneDepth)
            }

            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            sessionRunning = true

            // Coaching helps the user establish a stable world origin (IMU + visual features).
            installCoachingIfNeeded(on: sceneView)
        }

        private func installCoachingIfNeeded(on sceneView: ARSCNView) {
            if sceneView.subviews.contains(where: { $0 is ARCoachingOverlayView }) { return }
            let coaching = ARCoachingOverlayView()
            coaching.session = sceneView.session
            coaching.goal = .tracking
            coaching.activatesAutomatically = true
            coaching.translatesAutoresizingMaskIntoConstraints = false
            sceneView.addSubview(coaching)
            NSLayoutConstraint.activate([
                coaching.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor),
                coaching.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor),
                coaching.topAnchor.constraint(equalTo: sceneView.topAnchor),
                coaching.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor)
            ])
        }

        func handleUpdates(on sceneView: ARSCNView) {
            if exportTrigger.wrappedValue != lastHandledExportTrigger {
                lastHandledExportTrigger = exportTrigger.wrappedValue
                performExport(from: sceneView)
            }

            if pauseSession.wrappedValue {
                if sessionRunning {
                    sceneView.session.pause()
                    sessionRunning = false
                }
                return
            }

            if !sessionRunning {
                startSessionIfNeeded(on: sceneView)
            }

            publishMeshCount(from: sceneView.session)
        }

        // MARK: - ARSCNViewDelegate

        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard anchor is ARMeshAnchor else { return nil }
            return SCNNode()
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let meshAnchor = anchor as? ARMeshAnchor else { return }
            let geometryNode = makeMeshNode(from: meshAnchor)
            node.addChildNode(geometryNode)
            meshNodeCount += 1
            if let sceneView {
                publishMeshCount(from: sceneView.session)
            }
        }

        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let meshAnchor = anchor as? ARMeshAnchor else { return }
            node.childNodes.forEach { $0.removeFromParentNode() }
            node.addChildNode(makeMeshNode(from: meshAnchor))
            if let sceneView {
                publishMeshCount(from: sceneView.session)
            }
        }

        func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARMeshAnchor else { return }
            meshNodeCount = max(0, meshNodeCount - 1)
            if let sceneView {
                publishMeshCount(from: sceneView.session)
            }
        }

        private func makeMeshNode(from meshAnchor: ARMeshAnchor) -> SCNNode {
            let fill = SCNNode(geometry: makeSCNGeometry(from: meshAnchor.geometry))
            fill.geometry?.materials = [meshMaterial]
            fill.renderingOrder = 0

            let wire = SCNNode(geometry: makeSCNGeometry(from: meshAnchor.geometry))
            wire.geometry?.materials = [wireMaterial]
            wire.renderingOrder = 1

            let root = SCNNode()
            root.addChildNode(fill)
            root.addChildNode(wire)
            return root
        }

        private func makeSCNGeometry(from geometry: ARMeshGeometry) -> SCNGeometry {
            // Copy into CPU arrays — wrapping ARKit Metal buffers in SCNGeometrySource
            // often yields invisible/empty meshes even when anchors exist.
            let vertexCount = geometry.vertices.count
            var positions: [SCNVector3] = []
            positions.reserveCapacity(vertexCount)
            for index in 0..<vertexCount {
                let v = geometry.vertex(at: UInt32(index))
                positions.append(SCNVector3(v.x, v.y, v.z))
            }

            let faces = geometry.faces
            let indicesPerFace = faces.indexCountPerPrimitive
            var indices: [UInt32] = []
            indices.reserveCapacity(faces.count * indicesPerFace)
            for faceIndex in 0..<faces.count {
                for offset in 0..<indicesPerFace {
                    let byteOffset = (faceIndex * indicesPerFace + offset) * faces.bytesPerIndex
                    let pointer = faces.buffer.contents().advanced(by: byteOffset)
                    if faces.bytesPerIndex == 2 {
                        indices.append(UInt32(pointer.assumingMemoryBound(to: UInt16.self).pointee))
                    } else {
                        indices.append(pointer.assumingMemoryBound(to: UInt32.self).pointee)
                    }
                }
            }

            let vertexSource = SCNGeometrySource(vertices: positions)
            let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt32>.size)
            let element = SCNGeometryElement(
                data: indexData,
                primitiveType: .triangles,
                primitiveCount: faces.count,
                bytesPerIndex: MemoryLayout<UInt32>.size
            )
            return SCNGeometry(sources: [vertexSource], elements: [element])
        }

        private func publishMeshCount(from session: ARSession) {
            let count = session.currentFrame?.anchors.compactMap { $0 as? ARMeshAnchor }.count
                ?? meshNodeCount
            DispatchQueue.main.async {
                if self.meshAnchorCount.wrappedValue != count {
                    self.meshAnchorCount.wrappedValue = count
                }
            }
        }

        private func performExport(from sceneView: ARSCNView) {
            guard let frame = sceneView.session.currentFrame else {
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

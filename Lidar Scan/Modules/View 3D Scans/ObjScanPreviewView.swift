//
//  ObjScanPreviewView.swift
//  Lidar Scan
//

import SceneKit
import SwiftUI

/// SceneKit preview for exported room `.obj` scans (AR Quick Look does not show OBJ).
struct ObjScanPreviewView: View {
    let fileURL: URL
    let onClose: () -> Void
    @State private var loadError = ""

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let scene = loadScene() {
                SceneView(
                    scene: scene,
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                )
                .ignoresSafeArea()
                .background(Color.black)
            } else {
                ContentUnavailableView(
                    "Не удалось открыть модель",
                    systemImage: "exclamationmark.triangle",
                    description: Text(loadError.isEmpty ? fileURL.lastPathComponent : loadError)
                )
            }

            Button {
                onClose()
            } label: {
                Label("Закрыть", systemImage: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .padding()
            }
            .accessibilityLabel("Закрыть")
        }
    }

    private func loadScene() -> SCNScene? {
        do {
            let scene = try SCNScene(url: fileURL, options: [
                .checkConsistency: true,
                .flattenScene: true
            ])
            scene.background.contents = UIColor.black
            // Ensure meshes are visible with double-sided materials.
            scene.rootNode.enumerateChildNodes { node, _ in
                guard let geometry = node.geometry else { return }
                for material in geometry.materials {
                    material.isDoubleSided = true
                    material.lightingModel = .blinn
                }
            }
            return scene
        } catch {
            loadError = error.localizedDescription
            return nil
        }
    }
}

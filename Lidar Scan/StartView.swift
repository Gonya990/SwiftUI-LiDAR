//
//  StartView.swift
//  Lidar Scan
//
//  Created by Cedan Misquith on 27/04/25.
//

import SwiftUI
import ARKit
import RealityKit

struct StartView: View {
    @State var shouldNavigateToScanView: Bool = false
    @State var shouldNavigateToObjectScan: Bool = false
    @State var shouldNavigateToViewList: Bool = false
    func isLidarCapable() -> Bool {
        let supportLiDAR = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
        guard supportLiDAR else {
            print("LiDAR isn't supported here")
            return false
        }
        return true
    }
    var body: some View {
        NavigationStack {
            if  isLidarCapable() {
                VStack(spacing: 16) {
                    Text("LiDAR 3D Scanner")
                        .font(.title2.bold())
                    Text("Комнаты — быстрая LiDAR-сетка OBJ. Предметы — детальный текстурированный USDZ через Object Capture.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button {
                        shouldNavigateToScanView = true
                    } label: {
                        Label("Сканировать комнату", systemImage: "viewfinder")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button {
                        shouldNavigateToObjectScan = true
                    } label: {
                        Label("Сканировать предмет", systemImage: "cube.transparent")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!ObjectCaptureSession.isSupported)

                    if !ObjectCaptureSession.isSupported {
                        Text("Object Capture недоступен на этом устройстве.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        shouldNavigateToViewList = true
                    } label: {
                        Label("Мои 3D-сканы", systemImage: "folder")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .navigationDestination(isPresented: $shouldNavigateToScanView) {
                    Capture3DScanView().navigationBarHidden(true)
                }
                .navigationDestination(isPresented: $shouldNavigateToObjectScan) {
                    ContentView()
                        .environment(AppDataModel.instance)
                        .navigationBarHidden(true)
                }
                .navigationDestination(isPresented: $shouldNavigateToViewList) {
                    View3DScansView().navigationBarHidden(true)
                }
            } else {
                VStack(alignment: .center) {
                    Text("This Device is not capable of a 3D scan, as it is missing the Lidar Sensor.")
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

#Preview {
    StartView()
}

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
                    Text("LiDAR 3D-сканер")
                        .font(.title2.bold())
                    Text("Комната — LiDAR-сетка OBJ (голубая сетка на экране). Предмет — один объект в кадре, объёмная USDZ-модель через Object Capture.")
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

                    Text("Сканируй один предмет целиком: убери фон и лишние вещи, зафиксируй объект, обойди его по кругу. Лучше всего — матовые поверхности с текстурой и ровный свет. Не снимай всю комнату в режиме предмета.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if !ObjectCaptureSession.isSupported {
                        Text("Сканирование предметов недоступно на этом устройстве.")
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
                    Text("На этом устройстве нет датчика LiDAR, поэтому 3D-сканирование недоступно.")
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

#Preview {
    StartView()
}

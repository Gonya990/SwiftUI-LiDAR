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

                    Text("Перед сканированием предмета уберите сыпучие и движущиеся детали. Предмет должен оставаться неподвижным и неизменным; лучше всего подходят матовые поверхности с заметной текстурой и ровный рассеянный свет.")
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

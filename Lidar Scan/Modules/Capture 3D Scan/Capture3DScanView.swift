//
//  Capture3DScanView.swift
//  Lidar Scan
//

import SwiftUI

struct Capture3DScanView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State private var exportTrigger = 0
    @State private var exportFileName = ""
    @State private var exportResult: ScanExportResult = .idle
    @State private var pauseSession = false
    @State private var showHint = true
    @State private var statusMessage = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            ARWrapperView(
                exportTrigger: $exportTrigger,
                exportFileName: $exportFileName,
                exportResult: $exportResult,
                pauseSession: $pauseSession
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                if showHint {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("1. Медленно обходи объект / комнату (30–60 сек)")
                        Text("2. Белая сетка = LiDAR видит поверхности")
                        Text("3. Когда сетка покроет объект — нажми «Экспортировать»")
                    }
                    .font(.footnote)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture { showHint = false }
                }

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                HStack {
                    Button { mode.wrappedValue.dismiss() } label: {
                        Text("Назад")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)

                Button { beginExport() } label: {
                    Text("Экспортировать 3D-модель")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: exportResult) { result in
            switch result {
            case .idle:
                break
            case .success(let fileURL):
                pauseSession = false
                statusMessage = "Сохранено: \(fileURL.lastPathComponent)"
                savedAlert(fileURL: fileURL)
            case .failed(let message):
                pauseSession = false
                statusMessage = message
                simpleAlert(title: "Не удалось экспортировать", message: message) {
                    exportResult = .idle
                }
            }
        }
    }

    private func beginExport() {
        pauseSession = true
        alertView(
            title: "Сохранить скан",
            message: "Введите имя файла",
            hintText: "стол-на-кухне"
        ) { text in
            exportFileName = text
            statusMessage = "Сохранение…"
            exportTrigger += 1
        } secondaryAction: {
            pauseSession = false
        }
    }

    private func savedAlert(fileURL: URL) {
        let alert = UIAlertController(
            title: "3D-скан сохранён",
            message: "Файл виден в «Файлы» → «На моём iPhone» → «Igor G-LIDAR» → Scans → Rooms.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Поделиться / Сохранить в Файлы", style: .default) { _ in
            let share = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            self.rootController().present(share, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Готово", style: .cancel) { _ in
            exportResult = .idle
            mode.wrappedValue.dismiss()
        })
        rootController().present(alert, animated: true)
    }

    private func simpleAlert(title: String, message: String, onOk: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: .default) { _ in onOk() })
        rootController().present(alert, animated: true)
    }

    private func rootController() -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            return UIViewController()
        }
        return root
    }
}

#Preview {
    Capture3DScanView()
}

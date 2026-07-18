//
//  View3DScansView.swift
//  Lidar Scan
//

import SwiftUI

private struct ScanFile: Identifiable {
    let url: URL
    let modifiedAt: Date
    let size: Int64

    var id: URL { url }
    var name: String { url.lastPathComponent }
    var kind: String { url.pathExtension.uppercased() }

    func relativePath(from documentsDirectory: URL) -> String {
        url.path.replacingOccurrences(of: documentsDirectory.path + "/", with: "")
    }
}

struct View3DScansView: View {
    @Environment(\.presentationMode) private var mode: Binding<PresentationMode>
    @State private var files: [ScanFile] = []
    @State private var previewFile: ScanFile?
    @State private var loadError = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Label("Назад", systemImage: "chevron.left")
                }
                Spacer()
                Text("Мои 3D-сканы")
                    .font(.headline)
                Spacer()
                Button {
                    fetchFiles()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Обновить")
            }
            .padding()

            if files.isEmpty {
                ContentUnavailableView(
                    "Сканов пока нет",
                    systemImage: "cube.transparent",
                    description: Text(loadError.isEmpty
                                      ? "Создайте скан комнаты или предмета."
                                      : loadError)
                )
            } else {
                List {
                    ForEach(files) { file in
                        VStack(alignment: .leading, spacing: 8) {
                            Button {
                                previewFile = file
                            } label: {
                                HStack {
                                    Image(systemName: file.kind == "USDZ" ? "cube.fill" : "square.3.layers.3d")
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(file.name)
                                            .font(.headline)
                                        Text(fileDetails(file))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "eye")
                                }
                            }
                            .buttonStyle(.plain)

                            ShareLink(item: file.url) {
                                Label("Поделиться / Сохранить в Файлы", systemImage: "square.and.arrow.up")
                                    .font(.subheadline)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                removeFile(file)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
                .refreshable {
                    fetchFiles()
                }
            }

            Text("Также доступны в «Файлы» → «На моём iPhone» → «Igor G-LIDAR».")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchFiles()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            fetchFiles()
        }
        .fullScreenCover(item: $previewFile) { file in
            ModelView(modelFile: file.url) {
                previewFile = nil
            }
            .ignoresSafeArea()
        }
    }

    private var documentsDirectory: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private func fetchFiles() {
        guard let documentsDirectory else {
            loadError = "Папка Documents недоступна."
            files = []
            return
        }

        do {
            try FileManager.default.createDirectory(
                at: documentsDirectory.appendingPathComponent("Scans", isDirectory: true),
                withIntermediateDirectories: true
            )
            guard let enumerator = FileManager.default.enumerator(
                at: documentsDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else {
                throw CocoaError(.fileReadUnknown)
            }

            var discovered: [ScanFile] = []
            for case let url as URL in enumerator {
                guard ["obj", "usdz"].contains(url.pathExtension.lowercased()) else { continue }
                let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
                discovered.append(
                    ScanFile(
                        url: url,
                        modifiedAt: values.contentModificationDate ?? .distantPast,
                        size: Int64(values.fileSize ?? 0)
                    )
                )
            }
            files = discovered.sorted { $0.modifiedAt > $1.modifiedAt }
            loadError = ""
        } catch {
            files = []
            loadError = "Не удалось прочитать сканы: \(error.localizedDescription)"
        }
    }

    private func removeFile(_ file: ScanFile) {
        do {
            try FileManager.default.removeItem(at: file.url)
            fetchFiles()
        } catch {
            loadError = "Не удалось удалить файл: \(error.localizedDescription)"
        }
    }

    private func fileDetails(_ file: ScanFile) -> String {
        let size = ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file)
        guard let documentsDirectory else {
            return "\(file.kind) · \(size)"
        }
        return "\(file.kind) · \(size) · \(file.relativePath(from: documentsDirectory))"
    }
}

#Preview {
    View3DScansView()
}

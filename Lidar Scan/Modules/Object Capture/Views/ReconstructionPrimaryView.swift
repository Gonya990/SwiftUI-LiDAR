/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view to show during the reconstruction phase, with a progress update from the outputs `AsyncSequence`, until the model output is completed.
*/

import RealityKit
import SwiftUI
import os

private let logger = Logger(subsystem: GuidedCaptureSampleApp.subsystem, category: "ReconstructionPrimaryView")

struct ReconstructionPrimaryView: View {
    @Environment(AppDataModel.self) var appModel
    let outputFile: URL

    @State private var completed: Bool = false
    @State private var cancelled: Bool = false

    var body: some View {
        if completed && !cancelled {
            ModelView(modelFile: outputFile, endCaptureCallback: { [weak appModel] in
                appModel?.endCapture()
            })
            .onAppear(perform: {
                UIApplication.shared.isIdleTimerDisabled = false
            })
        } else {
            ReconstructionProgressView(outputFile: outputFile,
                                       completed: $completed,
                                       cancelled: $cancelled)
        }
    }
}

struct ReconstructionProgressView: View {
    @Environment(AppDataModel.self) var appModel
    let outputFile: URL
    @Binding var completed: Bool
    @Binding var cancelled: Bool

    @State private var progress: Float = 0
    @State private var estimatedRemainingTime: TimeInterval?
    @State private var processingStageDescription: String?
    @State private var pointCloud: PhotogrammetrySession.PointCloud?
    @State private var gotError: Bool = false
    @State private var errorMessage = ""
    @State private var isCancelling: Bool = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var padding: CGFloat {
        horizontalSizeClass == .regular ? 60.0 : 24.0
    }
    private func isReconstructing() -> Bool {
        return !completed && !gotError && !cancelled
    }

    var body: some View {
        VStack(spacing: 0) {
            if isReconstructing() {
                HStack {
                    Button(action: {
                        logger.log("Canceling...")
                        isCancelling = true
                        appModel.photogrammetrySession?.cancel()
                    }, label: {
                        Text(LocalizedString.cancel)
                            .font(.headline)
                            .bold()
                            .padding(30)
                            .foregroundColor(.blue)
                    })
                    .padding(.trailing)

                    Spacer()
                }
            }

            Spacer()

            TitleView()

            Spacer()

            ProgressBarView(progress: progress,
                            estimatedRemainingTime: estimatedRemainingTime,
                            processingStageDescription: processingStageDescription)
            .padding(padding)

            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
        .alert(LocalizedString.failureTitle, isPresented: $gotError) {
            Button(LocalizedString.startNewScan) {
                logger.log("Calling restart after reconstruction failure...")
                appModel.state = .restart
            }
        } message: {
            Text(errorMessage)
        }
        .task {
            precondition(appModel.state == .reconstructing)
            assert(appModel.photogrammetrySession != nil)
            guard let session = appModel.photogrammetrySession else {
                logger.error("Session unavailable from photogrammetry session.")

                return
            }

            let fileManager = FileManager.default
            let temporaryOutput = outputFile.deletingLastPathComponent()
                .appendingPathComponent(".model-\(UUID().uuidString).usdz")
            try? fileManager.removeItem(at: temporaryOutput)
            defer {
                // A successful promotion moves this file, so this is a no-op on success.
                // On every failure/cancellation path it prevents stale USDZ files accumulating.
                try? fileManager.removeItem(at: temporaryOutput)
            }

            let outputs = UntilProcessingCompleteFilter(input: session.outputs)
            do {
                try session.process(requests: [.modelFile(url: temporaryOutput, detail: .reduced)])
            } catch {
                logger.error("Processing the session failed: \(String(describing: error))")
                errorMessage = reconstructionErrorMessage(for: error)
                gotError = true
                return
            }
            for await output in outputs {
                switch output {
                    case .inputComplete:
                        break
                    case .requestProgress(let request, fractionComplete: let fractionComplete):
                        if case .modelFile = request {
                            progress = Float(fractionComplete)
                        }
                    case .requestProgressInfo(let request, let progressInfo):
                        if case .modelFile = request {
                            estimatedRemainingTime = progressInfo.estimatedRemainingTime
                            processingStageDescription = progressInfo.processingStage?.processingStageString
                        }
                    case .requestComplete(let request, _):
                        switch request {
                            case .modelFile(_, _, _):
                                logger.log("RequestComplete: .modelFile")
                            case .modelEntity(_, _), .bounds, .poses, .pointCloud:
                                // Not supported yet
                                break
                            @unknown default:
                                logger.warning("Received an output for an unknown request: \(String(describing: request))")
                        }
                    case .requestError(_, let requestError):
                        if !isCancelling {
                            errorMessage = reconstructionErrorMessage(for: requestError, requestFailed: true)
                            gotError = true
                        }
                    case .processingComplete:
                        if !gotError {
                            do {
                                let values = try temporaryOutput.resourceValues(forKeys: [.fileSizeKey])
                                guard (values.fileSize ?? 0) > 0 else {
                                    throw CocoaError(.fileNoSuchFile)
                                }
                                try promoteReconstructedModel(
                                    from: temporaryOutput,
                                    to: outputFile,
                                    fileManager: fileManager
                                )
                                completed = true
                                appModel.state = .viewing
                            } catch {
                                logger.error("Finalizing reconstructed model failed: \(String(describing: error))")
                                errorMessage = reconstructionErrorMessage(for: error)
                                gotError = true
                            }
                        }
                    case .processingCancelled:
                        cancelled = true
                        appModel.state = .restart
                    case .invalidSample(id: _, reason: _), .skippedSample(id: _), .automaticDownsampling:
                        continue
                    case .stitchingIncomplete:
                        logger.log("stitchingIncomplete")
                    @unknown default:
                        logger.warning("Received an unknown output: \(String(describing: output))")
                    }
            }
            logger.log("Reconstruction task exit")
        }  // task
    }

    private func promoteReconstructedModel(
        from temporaryOutput: URL,
        to outputFile: URL,
        fileManager: FileManager
    ) throws {
        if fileManager.fileExists(atPath: outputFile.path) {
            // replaceItem is atomic on the same volume and preserves the previous model
            // if promotion of the new model fails.
            _ = try fileManager.replaceItemAt(outputFile, withItemAt: temporaryOutput)
        } else {
            // replaceItem requires an existing destination; the first export must use move.
            try fileManager.moveItem(at: temporaryOutput, to: outputFile)
        }
    }

    private func reconstructionErrorMessage(for error: Error, requestFailed: Bool = false) -> String {
        if let sessionError = error as? PhotogrammetrySession.Error {
            switch sessionError {
                case .insufficientStorage:
                    return LocalizedString.insufficientStorage
                case .invalidImages:
                    return LocalizedString.imagesRejected
                case .invalidOutput:
                    return LocalizedString.outputFailure
                @unknown default:
                    return requestFailed ? LocalizedString.imagesRejected : LocalizedString.genericFailure
            }
        }

        if let cocoaError = error as? CocoaError, cocoaError.code == .fileNoSuchFile {
            return LocalizedString.outputFailure
        }

        // RealityKit exposes some reconstruction failures only as an opaque request Error.
        // The stage is reliable even when its private error text or type changes.
        return requestFailed ? LocalizedString.imagesRejected : LocalizedString.genericFailure
    }

    struct LocalizedString {
        static let failureTitle = NSLocalizedString(
            "Reconstruction failed title",
            bundle: Bundle.main,
            value: "Не удалось создать 3D-модель",
            comment: "Alert title shown when on-device reconstruction fails."
        )
        static let startNewScan = NSLocalizedString(
            "Start new scan after reconstruction failure",
            bundle: Bundle.main,
            value: "Начать новый скан",
            comment: "Button that restarts object capture after reconstruction fails."
        )
        static let insufficientStorage = NSLocalizedString(
            "Reconstruction insufficient storage",
            bundle: Bundle.main,
            value: "На iPhone недостаточно свободного места для временной реконструкции. Освободите не менее 1 ГБ и повторите. Исходные фотографии сохранены в «Файлы» → «На моём iPhone» → «Igor G-LIDAR» → Scans → Objects.",
            comment: "Actionable message for insufficient reconstruction storage."
        )
        static let imagesRejected = NSLocalizedString(
            "Reconstruction images rejected",
            bundle: Bundle.main,
            value: "RealityKit не смог сопоставить фотографии этого предмета. Исходники сохранены в «Файлы» → «На моём iPhone» → «Igor G-LIDAR» → Scans → Objects. Для нового скана уберите сыпучие и движущиеся детали, не меняйте форму предмета, используйте матовый фон и сделайте три полных прохода при ровном свете.",
            comment: "Actionable message when captured images cannot form a model."
        )
        static let outputFailure = NSLocalizedString(
            "Reconstruction output failure",
            bundle: Bundle.main,
            value: "Не удалось сохранить готовую 3D-модель. Исходные фотографии сохранены в «Файлы» → «На моём iPhone» → «Igor G-LIDAR» → Scans → Objects. Проверьте свободное место и повторите обработку.",
            comment: "Actionable message when a reconstructed model cannot be saved."
        )
        static let genericFailure = NSLocalizedString(
            "Reconstruction generic failure",
            bundle: Bundle.main,
            value: "Исходные фотографии сохранены и не потеряны. Освободите место, проверьте ровный свет и неподвижность предмета, затем начните новый скан.",
            comment: "Fallback reconstruction failure message."
        )
        static let cancel = NSLocalizedString(
            "Cancel (Object Reconstruction)",
            bundle: Bundle.main,
            value: "Cancel",
            comment: "Button title to cancel reconstruction.")
    }

}

extension PhotogrammetrySession.Output.ProcessingStage {
    var processingStageString: String? {
        switch self {
            case .preProcessing:
                return NSLocalizedString(
                    "Preprocessing (Reconstruction)",
                    bundle: Bundle.main,
                    value: "Preprocessing…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .imageAlignment:
                return NSLocalizedString(
                    "Aligning Images (Reconstruction)",
                    bundle: Bundle.main,
                    value: "Aligning Images…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .pointCloudGeneration:
                return NSLocalizedString(
                    "Generating Point Cloud (Reconstruction)",
                    bundle: Bundle.main,
                    value: "Generating Point Cloud…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .meshGeneration:
                return NSLocalizedString(
                    "Generating Mesh (Reconstruction)",
                    bundle: Bundle.main,
                    value: "Generating Mesh…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .textureMapping:
                return NSLocalizedString(
                    "Mapping Texture (Reconstruction)",
                    bundle: Bundle.main,
                    value: "Mapping Texture…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .optimization:
                return NSLocalizedString(
                    "Optimizing (Reconstruction)",
                    bundle: Bundle.main,
                    value: "Optimizing…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            default:
                return nil
            }
    }
}

private struct TitleView: View {
    var body: some View {
        Text(LocalizedString.processingTitle)
            .font(.largeTitle)
            .fontWeight(.bold)

    }

    private struct LocalizedString {
        static let processingTitle = NSLocalizedString(
            "Processing title (Object Capture)",
            bundle: Bundle.main,
            value: "Processing",
            comment: "Title of processing view during processing phase."
        )
    }
}

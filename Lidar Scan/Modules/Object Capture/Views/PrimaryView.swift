/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main view that includes both the image capture and reconstruction.
*/

import SwiftUI

import os

private let logger = Logger(subsystem: GuidedCaptureSampleApp.subsystem, category: "PrimaryView")

struct PrimaryView: View {
    @Environment(AppDataModel.self) var appModel

    @State private var showReconstructionView: Bool = false
    @State private var showErrorAlert: Bool = false
    private var showProgressView: Bool {
        appModel.state == .completed || appModel.state == .restart || appModel.state == .ready
    }

    var body: some View {
        VStack {
            if appModel.state == .capturing {
                if let session = appModel.objectCaptureSession {
                    CapturePrimaryView(session: session)
                }
            } else if showProgressView {
                CircularProgressView()
            }
        }
        .onChange(of: appModel.state) { _, newState in
            if newState == .failed {
                showErrorAlert = true
                showReconstructionView = false
            } else {
                showErrorAlert = false
                showReconstructionView = newState == .reconstructing || newState == .viewing
            }
        }
        .sheet(isPresented: $showReconstructionView) {
            if let folderManager = appModel.captureFolderManager {
                ReconstructionPrimaryView(outputFile: folderManager.modelsFolder.appendingPathComponent("model-mobile.usdz"))
                    .interactiveDismissDisabled()
            }
        }
        .alert(failureTitle, isPresented: $showErrorAlert) {
            Button(LocalizedString.restart) {
                logger.log("Calling restart...")
                appModel.state = .restart
            }
        } message: {
            Text(failureMessage)
        }
    }

    private var failureTitle: String {
        appModel.failureContext == .reconstruction
            ? LocalizedString.reconstructionSetupFailureTitle
            : LocalizedString.captureFailureTitle
    }

    private var failureMessage: String {
        appModel.failureContext == .reconstruction
            ? LocalizedString.reconstructionSetupFailureMessage
            : LocalizedString.captureFailureMessage
    }

    private enum LocalizedString {
        static let captureFailureTitle = NSLocalizedString(
            "Capture failed title",
            bundle: Bundle.main,
            value: "Capture stopped",
            comment: "Alert title shown when object capture fails."
        )
        static let restart = NSLocalizedString(
            "Restart capture after failure",
            bundle: Bundle.main,
            value: "Start again",
            comment: "Button that restarts object capture after a failure."
        )
        static let captureFailureMessage = NSLocalizedString(
            "Capture failed guidance",
            bundle: Bundle.main,
            value: "Check the lighting, keep the object still, and try again. Captured photos remain in the Scans/Objects folder.",
            comment: "Actionable guidance after object capture fails."
        )
        static let reconstructionSetupFailureTitle = NSLocalizedString(
            "Reconstruction setup failed title",
            bundle: Bundle.main,
            value: "Couldn’t start reconstruction",
            comment: "Alert title shown when the reconstruction session cannot start."
        )
        static let reconstructionSetupFailureMessage = NSLocalizedString(
            "Reconstruction setup failed guidance",
            bundle: Bundle.main,
            value: "The captured photos are still saved in Scans/Objects. Free at least 1 GB of storage, keep the app open, and try processing a new scan.",
            comment: "Actionable guidance when the reconstruction session cannot start."
        )
    }
}

private struct CircularProgressView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .light ? .black : .white))
                Spacer()
            }
            Spacer()
        }
    }
}

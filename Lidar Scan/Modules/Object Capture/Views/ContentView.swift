/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The top-level app view.
*/

import SwiftUI
import os

private let logger = Logger(subsystem: GuidedCaptureSampleApp.subsystem, category: "ContentView")

/// The root of the SwiftUI View graph.
struct ContentView: View {
    @Environment(AppDataModel.self) var appModel

    var body: some View {
        PrimaryView()
            .onAppear(perform: {
                UIApplication.shared.isIdleTimerDisabled = true
                if appModel.state == .notSet {
                    appModel.state = .ready
                }
            })
            .onDisappear(perform: {
                UIApplication.shared.isIdleTimerDisabled = false
                appModel.exitCaptureFlow()
            })
    }
}

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that generates human-readable strings for each Feedback state.
*/

import RealityKit
import SwiftUI

/// Keeps the UI string conversions all in one place for simplicity
final class FeedbackMessages {
    /// Returns the human readable string to display for the given feedback.  If there are more than one feedback entries, they
    /// will be concatenated together on multi-lines ('\n\ separated).
    static func getFeedbackString(for feedback: ObjectCaptureSession.Feedback, captureMode: AppDataModel.CaptureMode) -> String? {
           switch feedback {
               case .objectTooFar:
                   if captureMode == .area { return nil }
                   return "Подойди ближе к предмету"
               case .objectTooClose:
                   if captureMode == .area { return nil }
                   return "Отойди чуть дальше"
               case .environmentTooDark:
                   return "Нужно больше света"
               case .environmentLowLight:
                   return "Рекомендуется больше света"
               case .movingTooFast:
                   return "Двигайся медленнее"
               case .outOfFieldOfView:
                   return "Наведи камеру на предмет"
               default: return nil
           }
    }
}


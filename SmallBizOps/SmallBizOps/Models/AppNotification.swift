import SwiftUI

enum NotificationKind: Equatable {
    case lowStock
    case delayedOrder
    case activity

    var icon: String {
        switch self {
        case .lowStock: return "shippingbox.fill"
        case .delayedOrder: return "exclamationmark.triangle.fill"
        case .activity: return "checkmark.circle.fill"
        }
    }

    var tone: BadgeTone {
        switch self {
        case .lowStock: return .warning
        case .delayedOrder: return .danger
        case .activity: return .success
        }
    }
}

struct AppNotification: Identifiable {
    let id: String
    let kind: NotificationKind
    let title: String
    let message: String
    let createdAt: Date
    let destination: Screen?
}

import Foundation

enum TaskPriority: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var tone: BadgeTone {
        switch self {
        case .high: return .danger
        case .medium: return .warning
        case .low: return .neutral
        }
    }
}

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let relatedTo: String
    let time: String
    let priority: TaskPriority
    var isCompleted: Bool = false
}

import Foundation

struct Business {
    let ownerName: String
    let ownerInitials: String
    let businessName: String
    let role: String
    let dateLabel: String
}

struct SettingsRow: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let subtitle: String
}

struct SettingsGroup: Identifiable {
    let id = UUID()
    let title: String
    let rows: [SettingsRow]
}

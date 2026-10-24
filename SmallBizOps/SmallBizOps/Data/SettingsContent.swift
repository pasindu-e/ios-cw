import Foundation

/// Static configuration for the Settings screen's grouped rows. Subtitles
/// shown here are placeholders — `SettingsView.rowSubtitle(for:)` overrides
/// the ones backed by live store data (e.g. supplier count, business name).
enum SettingsContent {
    static let settingsGroups: [SettingsGroup] = [
        SettingsGroup(title: "BUSINESS", rows: [
            SettingsRow(iconName: "building.2", title: "Business profile", subtitle: "Northstar Goods"),
            SettingsRow(iconName: "map", title: "Suppliers & Map", subtitle: "Suppliers"),
            SettingsRow(iconName: "exclamationmark.triangle", title: "Stock thresholds", subtitle: "2 custom rules"),
            SettingsRow(iconName: "bell", title: "Notifications", subtitle: "Daily brief at 8:30 AM"),
        ]),
        SettingsGroup(title: "DATA & PRIVACY", rows: [
            SettingsRow(iconName: "icloud", title: "Sync status", subtitle: "Synced just now"),
            SettingsRow(iconName: "shield", title: "On-device processing", subtitle: "Private by default"),
            SettingsRow(iconName: "faceid", title: "Face ID", subtitle: "Enabled"),
        ]),
        SettingsGroup(title: "ABOUT", rows: [
            SettingsRow(iconName: "info.circle", title: "About SmallBizOps", subtitle: "Version 1.0"),
            SettingsRow(iconName: "shield", title: "Privacy & security", subtitle: "Learn more"),
        ]),
    ]
}

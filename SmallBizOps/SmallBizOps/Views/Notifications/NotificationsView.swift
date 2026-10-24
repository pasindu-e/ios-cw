import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Notifications", onBack: { router.go(.home) }) {
                    if store.unreadNotificationCount > 0 {
                        Button("Mark all read") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                store.markAllNotificationsRead()
                            }
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.appBlue)
                        .buttonStyle(.press)
                    }
                }

                if store.notifications.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.notifications) { notification in
                            row(for: notification)
                        }
                    }
                    .padding(.top, 6)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
    }

    private func row(for notification: AppNotification) -> some View {
        let isRead = store.isNotificationRead(notification.id)

        return Button {
            store.markNotificationRead(notification.id)
            if let destination = notification.destination {
                router.go(destination)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: notification.kind.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(notification.kind.tone.foreground)
                    .frame(width: 34, height: 34)
                    .background(notification.kind.tone.background)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(notification.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.appNavy)
                        .multilineTextAlignment(.leading)
                    Text(notification.message)
                        .font(.system(size: 12))
                        .foregroundColor(.appMuted)
                        .multilineTextAlignment(.leading)
                    Text(Self.relativeFormatter.localizedString(for: notification.createdAt, relativeTo: Date()))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.appLightMuted)
                        .padding(.top, 2)
                }

                Spacer(minLength: 0)

                if !isRead {
                    Circle().fill(Color.appTeal).frame(width: 8, height: 8).padding(.top, 4)
                }
            }
            .padding(12)
            .appCard()
            .opacity(isRead ? 0.65 : 1)
        }
        .buttonStyle(.press)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bell.slash")
                .font(.system(size: 30))
                .foregroundColor(.appLightMuted)
            Text("You're all caught up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appNavy)
            Text("New alerts about stock, orders, and activity will show up here.")
                .font(.system(size: 12))
                .foregroundColor(.appMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    RootView()
        .environmentObject(AppRouter())
        .environmentObject(MockDataStore())
}

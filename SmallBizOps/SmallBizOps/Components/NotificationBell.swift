import SwiftUI

struct NotificationBell: View {
    let unreadCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.appNavy)
                    .clipShape(Circle())

                if unreadCount > 0 {
                    Text(unreadCount > 9 ? "9+" : "\(unreadCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, unreadCount > 9 ? 4 : 0)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Color.appDanger)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.appOffWhite, lineWidth: 1.5))
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.press)
        .accessibilityLabel(unreadCount > 0 ? "Notifications, \(unreadCount) unread" : "Notifications")
    }
}

#Preview {
    HStack(spacing: 12) {
        NotificationBell(unreadCount: 0) {}
        NotificationBell(unreadCount: 3) {}
        NotificationBell(unreadCount: 42) {}
    }
    .padding()
    .background(Color.appOffWhite)
}

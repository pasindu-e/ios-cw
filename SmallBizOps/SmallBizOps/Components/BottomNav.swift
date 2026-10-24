import SwiftUI

struct BottomNav: View {
    let current: Screen
    let go: (Screen) -> Void

    @Namespace private var indicator

    private let items: [(icon: String, label: String, screen: Screen)] = [
        ("house.fill", "Home", .home),
        ("shippingbox.fill", "Inventory", .inventory),
        ("doc.text.fill", "Orders", .orders),
        ("waveform.path.ecg", "Activity", .activity),
    ]

    private func isActive(_ screen: Screen) -> Bool {
        switch (current, screen) {
        case (.home, .home), (.inventory, .inventory), (.orders, .orders), (.activity, .activity):
            return true
        default:
            return false
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                let active = isActive(item.screen)
                Button {
                    if !active {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                    go(item.screen)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.system(size: 18, weight: .semibold))
                        if active {
                            Text(item.label)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                                .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                        }
                    }
                    .foregroundColor(active ? .white : Color(hex: "8B96A6"))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            if active {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appNavy, Color.appSlate],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .matchedGeometryEffect(id: "activeTab", in: indicator)
                                    .shadow(color: Color.appNavy.opacity(0.35), radius: 10, x: 0, y: 6)
                            }
                        }
                    )
                }
                .buttonStyle(.press)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: current)
        .padding(6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .stroke(Color.appLine.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: AppShadow.elevated, radius: 20, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .padding(.top, 8)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomNav(current: .home) { _ in }
    }
    .background(Color.appOffWhite)
}

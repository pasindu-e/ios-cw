import SwiftUI

struct ProductDetailView: View {
    let sku: String
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore

    private var product: Product? { store.product(sku: sku) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Product details", onBack: { router.go(.inventory) }) {
                    Button("Edit") {}
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.appBlue)
                        .buttonStyle(.press)
                }

                if let product {
                    productHero(product)
                    stockPanel(product)
                        .padding(.top, 16)

                    if product.status == .lowStock {
                        warningCard(product)
                            .padding(.top, 10)
                    }

                    Text("Stock history").font(.appSectionTitle()).padding(.top, 21).padding(.bottom, 10)
                    stockHistoryCard(product)

                    PrimaryButton(title: "Review Reorder Proposal", systemImage: "shippingbox") {
                        router.go(.reorder(sku: product.sku))
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
    }

    private func productHero(_ product: Product) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: "EEE5DA"), Color(hex: "DFD0BE")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 82, height: 82)
                Image(systemName: "shippingbox.fill").font(.system(size: 34)).foregroundColor(Color(hex: "796044"))
            }
            .padding(.bottom, 5)
            StatusBadge(text: product.status.rawValue, tone: product.status.tone)
            Text(product.name).font(.system(size: 20, weight: .bold))
            Text("\(product.sku) · \(product.category)").font(.appCaption()).foregroundColor(.appMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    private func stockPanel(_ product: Product) -> some View {
        HStack(spacing: 22) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CURRENT STOCK").font(.system(size: 10, weight: .heavy)).tracking(1).foregroundColor(Color(hex: "8592A8"))
                (Text("\(product.stock) ").font(.system(size: 28, weight: .bold)) + Text("units").font(.system(size: 10)).foregroundColor(Color(hex: "9CA8BA")))
                    .foregroundColor(.white)
            }
            Rectangle().fill(Color.white.opacity(0.12)).frame(width: 1)
            VStack(alignment: .leading, spacing: 4) {
                Text("MINIMUM").font(.system(size: 10, weight: .heavy)).tracking(1).foregroundColor(Color(hex: "8592A8"))
                (Text("\(product.minimum) ").font(.system(size: 28, weight: .bold)) + Text("units").font(.system(size: 10)).foregroundColor(Color(hex: "9CA8BA")))
                    .foregroundColor(Color(hex: "D2D9E4"))
            }
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 17)
        .background(Color.appNavy)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private func warningCard(_ product: Product) -> some View {
        HStack(spacing: 11) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.appDanger)
                .frame(width: 36, height: 36)
                .background(Color.kpiCoralBG)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text("Below your stock threshold").font(.appRowTitle())
                let days = product.averageDailyUsage > 0 ? max(1, Int(Double(product.stock) / product.averageDailyUsage)) : 0
                Text("At current usage, you may run out in \(days) day\(days == 1 ? "" : "s").").font(.appCaption()).foregroundColor(.appMuted)
            }
        }
        .padding(12)
        .background(Color(hex: "FFFAF1"))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous).stroke(Color(hex: "F4DFB5"), lineWidth: 1))
    }

    private func stockHistoryCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("LAST 30 DAYS").font(.system(size: 10, weight: .heavy)).tracking(1).foregroundColor(.appMuted)
                    Text("−18 units").font(.system(size: 17, weight: .bold))
                }
                Spacer()
                StatusBadge(text: "30 days", tone: .neutral)
            }
            StockHistoryChart(minimum: product.minimum)
                .frame(height: 100)
                .padding(.top, 6)
            HStack {
                Text("May 20")
                Spacer()
                Text("Jun 3")
                Spacer()
                Text("Today")
            }
            .font(.system(size: 8))
            .foregroundColor(.appLightMuted)
            .padding(.top, 5)
        }
        .padding(14)
        .appCard(padding: 0)
    }
}

private struct StockHistoryChart: View {
    let minimum: Int

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let points: [CGPoint] = [
                CGPoint(x: 0, y: 0.12), CGPoint(x: 0.26, y: 0.26), CGPoint(x: 0.45, y: 0.38),
                CGPoint(x: 0.67, y: 0.50), CGPoint(x: 0.81, y: 0.70), CGPoint(x: 1.0, y: 0.83),
            ].map { CGPoint(x: $0.x * w, y: $0.y * h) }

            ZStack(alignment: .topLeading) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0.62 * h))
                    path.addLine(to: CGPoint(x: w, y: 0.62 * h))
                }
                .stroke(Color.appDanger.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

                Text("Minimum \(minimum)")
                    .font(.system(size: 8))
                    .foregroundColor(.appDanger)
                    .offset(y: 0.62 * h - 12)

                Path { path in
                    path.move(to: points[0])
                    for point in points.dropFirst() { path.addLine(to: point) }
                }
                .stroke(Color(hex: "6E79D8"), lineWidth: 2.5)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addLine(to: points[0])
                    for point in points.dropFirst() { path.addLine(to: point) }
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.closeSubpath()
                }
                .fill(LinearGradient(colors: [Color.appIndigo.opacity(0.35), Color.appIndigo.opacity(0)], startPoint: .top, endPoint: .bottom))
            }
        }
        .overlay(Rectangle().fill(Color.appLine).frame(height: 1), alignment: .bottom)
    }
}

#Preview {
    ProductDetailView(sku: "COF-001").environmentObject(AppRouter()).environmentObject(MockDataStore())
}

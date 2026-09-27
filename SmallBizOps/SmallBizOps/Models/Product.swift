import Foundation

enum StockStatus: String {
    case lowStock = "Low stock"
    case inStock = "In stock"

    var tone: BadgeTone {
        switch self {
        case .lowStock: return .danger
        case .inStock: return .success
        }
    }
}

struct Product: Identifiable, Hashable {
    var id: String { sku }
    let name: String
    let sku: String
    let stock: Int
    let minimum: Int
    let status: StockStatus
    let category: String
    let supplier: String
    let unitCost: Double
    let averageDailyUsage: Double

    static func == (lhs: Product, rhs: Product) -> Bool { lhs.sku == rhs.sku }
    func hash(into hasher: inout Hasher) { hasher.combine(sku) }
}

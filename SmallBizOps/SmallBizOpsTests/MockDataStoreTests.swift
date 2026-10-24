import XCTest
@testable import SmallBizOps

@MainActor
final class MockDataStoreTests: XCTestCase {
    private var store: MockDataStore!

    private let lowStockProduct = Product(
        name: "Premium Coffee Beans", sku: "COF-001", stock: 4, minimum: 10,
        status: .lowStock, category: "Beverages", supplier: "Northline Roasters",
        unitCost: 12.50, averageDailyUsage: 1.4
    )
    private let criticalProduct = Product(
        name: "Paper Cups", sku: "SUP-014", stock: 2, minimum: 20,
        status: .lowStock, category: "Supplies", supplier: "Cascade Packaging Co.",
        unitCost: 3.25, averageDailyUsage: 2.6
    )
    private let inStockProduct = Product(
        name: "Vanilla Syrup", sku: "ING-022", stock: 28, minimum: 12,
        status: .inStock, category: "Ingredients", supplier: "Flavorworks Supply",
        unitCost: 8.10, averageDailyUsage: 0.9
    )

    private func makeOrder(id: String, status: OrderStatus) -> Order {
        Order(
            id: id, customer: "Jordan Lee", email: "jordan@example.com", phone: "555-0100",
            total: 72.0, status: status, time: "Due today", itemsLabel: "3 items",
            lineItems: [], shipping: 0, timeline: []
        )
    }

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "readNotificationIDs")
        store = MockDataStore()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "readNotificationIDs")
        store = nil
        super.tearDown()
    }

    func testLowStockAndAttentionCounts() {
        store.products = [lowStockProduct, criticalProduct, inStockProduct]
        store.orders = [makeOrder(id: "#ORD-1", status: .delayed), makeOrder(id: "#ORD-2", status: .pending)]

        XCTAssertEqual(store.lowStockCount, 2)
        XCTAssertEqual(store.openOrdersCount, 2)
        XCTAssertEqual(store.needsAttentionCount, 3) // 2 low stock + 1 delayed
    }

    func testFindingsHighPriorityForCriticallyLowStock() {
        store.products = [criticalProduct] // stock 2 <= minimum 20 / 2

        let findings = store.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .highPriority)
        XCTAssertTrue(findings.first?.title.contains("Paper Cups") ?? false)
    }

    func testFindingsMediumSeverityForNonCriticalLowStock() {
        let approachingMinimum = Product(
            name: "Northstar Tote Bag", sku: "MER-008", stock: 8, minimum: 10,
            status: .lowStock, category: "Merchandise", supplier: "Bluecrest Textiles",
            unitCost: 6.40, averageDailyUsage: 0.5
        )
        store.products = [approachingMinimum]

        let findings = store.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .medium)
    }

    func testFindingsIncludeDelayedOrders() {
        store.orders = [makeOrder(id: "#ORD-1048", status: .delayed)]

        let findings = store.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .highPriority)
        XCTAssertTrue(findings.first?.title.contains("#ORD-1048") ?? false)
    }

    func testNotificationsDerivedFromStockAndOrders() {
        store.products = [lowStockProduct]
        store.orders = [makeOrder(id: "#ORD-1", status: .delayed)]

        let notifications = store.notifications
        XCTAssertEqual(notifications.count, 2)
        XCTAssertTrue(notifications.contains { $0.kind == .lowStock })
        XCTAssertTrue(notifications.contains { $0.kind == .delayedOrder })
    }

    func testUnreadCountDecreasesAsNotificationsAreMarkedRead() {
        store.products = [lowStockProduct, criticalProduct]
        XCTAssertEqual(store.unreadNotificationCount, 2)

        let firstID = store.notifications[0].id
        store.markNotificationRead(firstID)
        XCTAssertEqual(store.unreadNotificationCount, 1)
        XCTAssertTrue(store.isNotificationRead(firstID))

        store.markAllNotificationsRead()
        XCTAssertEqual(store.unreadNotificationCount, 0)
    }
}

import XCTest
import SwiftUI
@testable import SmallBizOps

final class ModelTests: XCTestCase {

    // MARK: - Business

    func testOwnerInitialsFromFullName() {
        let business = Business(ownerName: "Maya Chen", businessName: "Northstar Goods", role: "Owner")
        XCTAssertEqual(business.ownerInitials, "MC")
    }

    func testOwnerInitialsFromSingleName() {
        let business = Business(ownerName: "Maya", businessName: "Northstar Goods", role: "Owner")
        XCTAssertEqual(business.ownerInitials, "M")
    }

    func testOwnerInitialsFallsBackWhenEmpty() {
        let business = Business(ownerName: "", businessName: "Northstar Goods", role: "Owner")
        XCTAssertEqual(business.ownerInitials, "?")
    }

    // MARK: - Currency formatting

    func testAsUSDFormatsWithDollarSignAndTwoDecimals() {
        XCTAssertEqual((1234.5).asUSD(), "$1,234.50")
        XCTAssertEqual((0.0).asUSD(), "$0.00")
    }

    // MARK: - Tone mappings

    func testStockStatusTone() {
        XCTAssertEqual(StockStatus.lowStock.tone.background, Color.badgeDangerBG)
        XCTAssertEqual(StockStatus.inStock.tone.background, Color.badgeSuccessBG)
    }

    func testTaskPriorityTone() {
        XCTAssertEqual(TaskPriority.high.tone.background, Color.badgeDangerBG)
        XCTAssertEqual(TaskPriority.medium.tone.background, Color.badgeWarningBG)
        XCTAssertEqual(TaskPriority.low.tone.background, Color.badgeNeutralBG)
    }

    func testOrderStatusTone() {
        XCTAssertEqual(OrderStatus.pending.tone.background, Color.badgeWarningBG)
        XCTAssertEqual(OrderStatus.processing.tone.background, Color.badgeInfoBG)
        XCTAssertEqual(OrderStatus.delayed.tone.background, Color.badgeDangerBG)
    }

    func testFindingSeverityTone() {
        XCTAssertEqual(FindingSeverity.highPriority.tone.background, Color.badgeDangerBG)
        XCTAssertEqual(FindingSeverity.medium.tone.background, Color.badgeWarningBG)
    }

    func testNotificationKindToneAndIcon() {
        XCTAssertEqual(NotificationKind.lowStock.tone.background, Color.badgeWarningBG)
        XCTAssertEqual(NotificationKind.delayedOrder.tone.background, Color.badgeDangerBG)
        XCTAssertEqual(NotificationKind.activity.tone.background, Color.badgeSuccessBG)

        XCTAssertEqual(NotificationKind.lowStock.icon, "shippingbox.fill")
        XCTAssertEqual(NotificationKind.delayedOrder.icon, "exclamationmark.triangle.fill")
        XCTAssertEqual(NotificationKind.activity.icon, "checkmark.circle.fill")
    }
}

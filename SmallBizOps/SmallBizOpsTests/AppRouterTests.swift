import XCTest
@testable import SmallBizOps

@MainActor
final class AppRouterTests: XCTestCase {

    func testDefaultScreenIsHome() {
        let router = AppRouter()
        XCTAssertEqual(router.screen, .home)
    }

    func testBottomNavVisibleOnlyOnTabScreens() {
        let router = AppRouter()

        for screen: Screen in [.home, .inventory, .orders, .activity] {
            router.go(screen)
            XCTAssertTrue(router.hasBottomNav, "Expected bottom nav for \(screen)")
        }

        for screen: Screen in [.running, .results, .settings, .tasks, .notifications, .suppliers] {
            router.go(screen)
            XCTAssertFalse(router.hasBottomNav, "Did not expect bottom nav for \(screen)")
        }
    }

    func testIsDarkScreenOnlyWhileRunning() {
        let router = AppRouter()

        router.go(.running)
        XCTAssertTrue(router.isDarkScreen)

        router.go(.home)
        XCTAssertFalse(router.isDarkScreen)
    }

    func testGoUpdatesScreen() {
        let router = AppRouter()
        router.go(.product(sku: "COF-001"))
        XCTAssertEqual(router.screen, .product(sku: "COF-001"))
    }
}

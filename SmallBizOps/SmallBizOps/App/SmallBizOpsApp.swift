import SwiftUI

@main
struct SmallBizOpsApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var store = MockDataStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(store)
        }
    }
}

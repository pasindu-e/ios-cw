import SwiftUI

@main
struct SmallBizOpsApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var store = MockDataStore()
    @StateObject private var auth = AuthStore()

    var body: some Scene {
        WindowGroup {
            Group {
                switch auth.stage {
                case .credentials:
                    LoginView()
                case .faceIDSetup:
                    FaceIDSetupView()
                case .authenticated:
                    RootView()
                }
            }
            .environmentObject(router)
            .environmentObject(store)
            .environmentObject(auth)
            .onAppear {
                auth.stage = .authenticated
                router.go(.settings)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    router.go(.home)
                    auth.signOut()
                }
            }
        }
    }
}

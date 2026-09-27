import SwiftUI
import LocalAuthentication

enum AuthStage {
    case credentials
    case faceIDSetup
    case authenticated
}

@MainActor
final class AuthStore: ObservableObject {
    @Published var stage: AuthStage = .credentials
    @Published var loginError: String?
    @Published var isCheckingBiometrics = false

    /// Mock credentials for this offline MVP — there is no backend.
    private let mockUsername = "pasindu"
    private let mockPassword = "12345678"

    /// Validates the mock credentials, then hands off to the Face ID
    /// enable/scan step rather than logging straight in.
    func signIn(username: String, password: String) {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.lowercased() == mockUsername.lowercased(), password == mockPassword else {
            loginError = "Incorrect username or password."
            return
        }
        loginError = nil
        withAnimation(.easeInOut(duration: 0.25)) {
            stage = .faceIDSetup
        }
    }

    /// Runs a real biometric prompt (works in Simulator via Features > Face ID)
    /// and reports success/failure without changing navigation state itself.
    func authenticateWithFaceID(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var evaluationError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &evaluationError) else {
            completion(false, "Face ID is not available on this device.")
            return
        }

        isCheckingBiometrics = true
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sign in to SmallBizOps") { [weak self] success, error in
            Task { @MainActor in
                self?.isCheckingBiometrics = false
                completion(success, success ? nil : "Face ID didn't match. Try again or continue without it.")
            }
        }
    }

    func completeLogin() {
        withAnimation(.easeInOut(duration: 0.25)) {
            stage = .authenticated
        }
    }

    func signOut() {
        withAnimation(.easeInOut(duration: 0.25)) {
            stage = .credentials
        }
    }
}

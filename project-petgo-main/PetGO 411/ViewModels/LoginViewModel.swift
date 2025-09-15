
import Foundation
import FirebaseAuth
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var navigateToHome: Bool = false
    
    func login() {
        // Trim whitespace
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // ensure fields are not empty
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            alertMessage = "Please enter an email and password"
            showAlert = true
            return
        }

        // Authenticate with Firebase
        Auth.auth().signIn(withEmail: trimmedEmail, password: trimmedPassword) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.alertMessage = "Login failed: \(error.localizedDescription)"
                print("Login failed: \(error.localizedDescription)") // for debugging
                self.showAlert = true
                return
            }
            
            // for debugging purposes, prints the current user being logged in
            print("Login successful") // for debugging
            if let userID = Auth.auth().currentUser?.uid {
                print("Logging in user: \(userID)")  // DEBUGGING ONLY
            } else {
                assertionFailure("Unexpected nil: No user logged in")
            }
            
            navigateToHome = true
        }
    }
}







import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore


// creates a new user in Firebase
class SignUpViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var navigateToHome = false
    
    init() {}

   
    
    // creates a user in the firebase database
    func create_account() {
        
        // function stops if validation() returns false
        guard Validation() else { return }
        
        // creates a user using Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            // If Firebase returns an error
            if let error = error {
                self.alertMessage = "Failed to create account: \(error.localizedDescription)"
                print(self.alertMessage) // for debugging
                self.showAlert = true
                return
            }
            
            // Get user ID
            guard let userID = result?.user.uid else {
                self.alertMessage = "Unexpected error: Missing user ID."
                print(self.alertMessage) // for debugging
                self.showAlert = true
                return
            }
            
            // Add user to Firestore
            insertUserAccount(ID: userID) {
                print("Calling insertUserAccount for ID: \(userID)")
                self.alertMessage = "Account Created!"
                print(self.alertMessage)  // for debugging
                self.navigateToHome = true
            }

        }
    }
    
    // inserts user into the firebase database
    private func insertUserAccount(ID: String, completion: @escaping () -> Void) {
        let newUserData: [String: Any] = [
            "ID": ID,
            "name": fullName,
            "email": email,
            "joined": Date().timeIntervalSince1970
        ]
        
        Firestore.firestore()
            .collection("Users").document(ID)
            .setData(newUserData) { error in
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                } else {
                    print("User successfully added to Firestore!")
                    print("Data being sent to Firestore: \(newUserData)")
                    completion() //Call this after success
                }
            }
    }

    
    // Validate creation of email, passsword, and full name fields, returns true if everything is valid
    private func Validation() -> Bool {
        
        // makes sure there is input in the email and password forms (fields are not empty)
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            alertMessage = "Fill Out All Fields!"
            print("Fill Out All Fields!") // for debugging
            showAlert = true
            return false
        }

        // makes sure email has "@" and "." in the string
        guard email.contains("@"), email.contains(".") else {
            alertMessage = "Enter a Valid Email!"
            showAlert = true
            return false
        }
        
        // makes sure password length is 6 characters or more
        guard password.count >= 6 else {
            alertMessage = "Password Too Short!"
            showAlert = true
            return false
        }
        
        return true
    }
    
}


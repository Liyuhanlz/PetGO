
import Foundation
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var navigateToLogin: Bool = false
    
    // current user from firestore databse
    @Published var currentUser: User? = nil
    
    init() {
        // upon creation of an instance, currentUser gets assigned the current logged in user
        fetchUser()
    }
    
    // get specific user from firestore, updates currentUser to current logged in user
    func fetchUser() {
        
        // function returns if no user is currently signed in
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is signed in. Stopping fetchUser()") // for debugging only
            return
        }
        
        
        // fetches current signed in user
        Firestore.firestore()
            .collection("Users").document(userID).getDocument { [weak self] snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    return
                }
                
                // uses User Struct
                DispatchQueue.main.async {
                    self?.currentUser = User(ID: data["ID"] as? String ?? "",
                                      name: data["name"] as? String ?? "",
                                      email: data["email"] as? String ?? "",
                                      joined: data["joined"] as? TimeInterval ?? 0)
                }
            }
        
        print("Fetched user: \(userID)") // for debugging only
        
    }

    func logout() {
        
        // for debugging purposes, prints the user current being logged out
        if let userID = Auth.auth().currentUser?.uid {
            print("Logging out user: \(userID)")  // DEBUGGING ONLY
        } else {
            assertionFailure("Unexpected nil: No user logged in")
        }
        
        // main logout functionality
        do {
            try Auth.auth().signOut()
            print("User Logged out successfully.") // for debugging only
        } catch {
            print("Error Logging out:  \(error.localizedDescription)") // for debugging only
        }
        
        navigateToLogin = true
        
    }
}


// User info and properties
struct User: Codable {
    let ID: String
    let name: String
    let email: String
    let joined: TimeInterval // when the user signed up or made an account
}



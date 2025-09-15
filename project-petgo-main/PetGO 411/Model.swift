import SwiftUI
import Foundation
import FirebaseAuth // for SessionManager class

// This file contains any extra or necessary code



extension Color {
    static let lightGreen = Color(red: 230/255, green: 255/255, blue: 230/255) // text color
    static let midGreen = Color(red: 200/255, green: 255/255, blue: 200/255) // darker text color
    static let dark = Color(red: 27 / 255, green: 29 / 255, blue: 31 / 255) // app background color
}

// used for the bottom bar navigation and within NavBar view file
enum ViewDestination {
    case home, journal, profile // can add or update views
}

// for global sessions 
class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        listenToAuthState()
    }
    
    private func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = user != nil
                print("Auth state changed. isLoggedIn = \(self?.isLoggedIn == true)")
            }
        }
    }
    
    deinit {
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
            print("Removed auth state listener")
        }
    }

}

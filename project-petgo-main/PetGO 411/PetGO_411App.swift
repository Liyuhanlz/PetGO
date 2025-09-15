
import SwiftUI
import FirebaseCore

// firebase code
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct PetGO_411App: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // for global session states
    @StateObject var session = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if session.isLoggedIn {
                    Home()
                } else {
                    Login()
                }
            }
            .environmentObject(session)
        }
    }
}








  



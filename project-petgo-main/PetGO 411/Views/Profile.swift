import SwiftUI

struct Profile: View {
    @StateObject var viewModel = ProfileViewModel()
    
    // Navigation Purposes, binding value from NavBar file
    @State private var selectedView: ViewDestination? = .profile
    
   
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.dark.ignoresSafeArea()
                
                VStack {
                    if let currentUser = viewModel.currentUser {
                        VStack {
                            Image(systemName: "person.crop.circle")
                                .foregroundStyle(Color.lightGreen)
                                .font(.system(size: 100))
                    
                            Text(currentUser.name)
                                .font(.system(size: 40))
                                .padding(.top, 20)
                                
                        }
                        .foregroundStyle(Color.lightGreen)
                        .padding(.top, 100)
                    } else {
                        Text("No User Logged In")
                            .foregroundColor(Color.lightGreen)
                            .padding(.top, 100)
                    }
                    
                    
                    
                    Button {
                        viewModel.logout()
                    } label : {
                        Text("Logout")
                            .padding(.horizontal)
                            .frame(width: 200, height: 80)
                            .foregroundStyle(Color.lightGreen)
                            .fontWeight(.bold)
                            .overlay(RoundedRectangle(cornerRadius:10)
                                .stroke(Color.lightGreen, style: StrokeStyle(lineWidth: 1)))
                    }
                    .padding(.top, 200)
                    
                    Spacer()
                    NavBar(selectedView: $selectedView)
                } // end of Vstack
                .navigationDestination(item: $selectedView) { view in
                    switch view {
                        case .home: Home().navigationBarBackButtonHidden(true)
                        case .journal: Journal().navigationBarBackButtonHidden(true)
                        case .profile: Profile().navigationBarBackButtonHidden(true)
                    }
                }
                
            } // end of ZStack
            .navigationDestination(isPresented: $viewModel.navigateToLogin) {
                Login().navigationBarBackButtonHidden(true)
            }
        } // end of Navigation Stack
    } // end of body
} // end of Profile struct

#Preview {
    Profile()
}

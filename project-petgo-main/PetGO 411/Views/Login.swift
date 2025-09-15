
import SwiftUI

struct Login: View {
    @StateObject var viewModel = LoginViewModel()
    
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color.dark.ignoresSafeArea()
                
                VStack {
                    Text("Login")
                        .font(.system(size: 50))
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.lightGreen)
                        .offset(y: 30)
                    
                    VStack {
                        HStack {
                            Text("Email")
                            Image(systemName: "envelope.fill")
                        }
                        TextField("Email", text: $viewModel.email)
                            .padding(.horizontal)
                            .frame(width: 300, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1)))
                        
                        HStack {
                            Text("Password")
                            Image(systemName: "lock.fill")
                        }
                        .offset(y: 15)

                        SecureField("Password", text: $viewModel.password)
                            .padding(.horizontal)
                            .frame(width: 300, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1)))
                            .offset(y: 15)

                        
                        Button {
                            viewModel.login()
                        } label : {
                            Text("Login →")
                                .padding(.horizontal)
                                .frame(width: 160, height: 50)
                                .foregroundStyle(Color.lightGreen)
                                .fontWeight(.bold)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: StrokeStyle(lineWidth: 1)))
                        }
                        .padding(.top, 35)
                        
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 15))
                            NavigationLink(destination: SignUp(),
                                           label: {
                                Text("Sign Up")
                                    .underline()
                                    .font(.system(size: 15))})
                                    .foregroundStyle(Color.midGreen)
                        }
                        .padding(.top, 10)
                       
                       
                    } // end of input VStack
                    .offset(y: 50)
                    .foregroundStyle(Color.lightGreen)
                    
                    Spacer()
                } // end of main VStack
            } // end of ZStack
            .navigationDestination(isPresented: $viewModel.navigateToHome) {
                Home().navigationBarBackButtonHidden(true)
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage)
            }
        } // end of NavigationStack
    } // end of body
} // end of Login struct

#Preview {
    Login()
}

import SwiftUI

struct SignUp: View {
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.dark.ignoresSafeArea()
                
                VStack {
                    Text("Sign Up")
                        .font(.system(size: 50))
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.lightGreen)
                    
                    VStack {
                        HStack {
                            Text("Full Name")
                            Image(systemName: "person.fill")
                        }
                        .offset(y: 5)
                        TextField("Full Name", text: $viewModel.fullName)
                            .padding(.horizontal)
                            .frame(width: 300, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1)))
                        
                        HStack {
                            Text("Email")
                            Image(systemName: "envelope.fill")
                        }
                        .offset(y: 10)
                        TextField("Email", text: $viewModel.email)
                            .padding(.horizontal)
                            .frame(width: 300, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1)))
                            .offset(y: 5)
                        
                        HStack {
                            Text("Password")
                            Image(systemName: "lock.fill")
                        }
                        .offset(y: 15)
                        SecureField("Password", text: $viewModel.password)
                            .padding(.horizontal)
                            .frame(width: 300, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1)))
                            .offset(y: 10)
                        
                        Button {
                            viewModel.create_account()
                        } label : {
                            Text("Sign Up →")
                                .padding(.horizontal)
                                .frame(width: 160, height: 50)
                                .foregroundStyle(Color.lightGreen)
                                .fontWeight(.bold)
                                .overlay(RoundedRectangle(cornerRadius:10)
                                    .stroke(style: StrokeStyle(lineWidth: 1)))
                        }
                        .padding(.top, 30)
        
                    } // end of input VStack
                    .offset(y: 15)
                    .foregroundStyle(Color.lightGreen)
                    Spacer()
                } // end of main VStack
            } // end of ZStack
            .navigationDestination(isPresented: $viewModel.navigateToHome) {
                Home()
            }
        } // end of NavigationStack
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    } // end of body
} // end of struct

#Preview {
    SignUp()
}


import SwiftUI
import PhotosUI

struct Home: View {
    @StateObject var viewModel = HomeViewModel()
    
    // Navigation Purposes, binding value from NavBar file
    @State private var selectedView: ViewDestination? = .home
    
    // shows the sheet to add a pet
    @State private var showSheet = false
    
    // show PetProfile sheet, for edit or creation of a pet
    @State private var petToEdit: PetModel? = nil
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.dark.ignoresSafeArea()
                VStack {
                    // top part of the view
                    HStack {
                        Text("Pets")
                            .foregroundStyle(Color.lightGreen)
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        Spacer()
                        // add a new pet
                        Button {
                            showSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.lightGreen)
                                .padding(.trailing, 20)
                        }
                    }
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                    // end of the top part of the view
                    
                    // all user pets
                    if viewModel.pets.isEmpty {
                        Text("No pets, add one now.")
                            .foregroundStyle(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.pets) { pet in
                                PetCard(name: pet.name, type: pet.type, age: pet.age, image: pet.image)
                                    .listRowBackground(Color.dark)
                                    .onTapGesture {
                                        petToEdit = pet // ← open edit mode
                                    }
                            }
                            .onDelete(perform: viewModel.deletePet)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden) // remove white background
                        .background(Color.dark)
                    }

                    
                    
                    
                    
                    Spacer()
                    NavBar(selectedView: $selectedView)
                }
                .navigationDestination(item: $selectedView) { view in
                    switch view {
                        case .home: Home().navigationBarBackButtonHidden(true)
                        case .journal: Journal().navigationBarBackButtonHidden(true)
                        case .profile: Profile().navigationBarBackButtonHidden(true)
                    }
                }
                .onAppear {
                    viewModel.fetchPets()
                }
                .fullScreenCover(isPresented: $showSheet, onDismiss: {
                       viewModel.fetchPets()
                }) {
                    PetProfile(mode: .create)
                }
                .fullScreenCover(item: $petToEdit, onDismiss: {
                    viewModel.fetchPets() // refresh when edit sheet closes
                }) { pet in
                    PetProfile(mode: .edit(pet))
                }
                
                

            } // end of ZStack
        } // end of Navigation Stack
    } // end of body
} // end of Home struct

struct textStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .bold()
            .font(.system(size: 19))
    }
}

#Preview {
    Home()
}





// view each Pet the user has
struct PetCard: View {
    let name: String
    let type: String
    let age: String
    let image: UIImage?

    var body: some View {
        HStack(spacing: 16) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
            } else {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.lightGreen)

                Text("\(type) | \(age)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.dark)
    }
}






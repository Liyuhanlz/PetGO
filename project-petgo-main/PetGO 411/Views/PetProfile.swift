///
//  ContentView.swift
//  TestCode
//
//  Created by csuftitan on 6/22/25.
// had issues testing on main file so I did this on an test project
//

import PhotosUI
import SwiftUI

struct PetProfile: View {
    @StateObject var viewModel = PetProfileViewModel()
    
    // All of these should be made Global in someway
    @State var name: String = ""
    @State var type: String = ""
    @State var age: String = ""     //Should be made into an Int later
    @State var weight: String = ""  //Should be made into an Int later
    @State var note: String = ""
    @State var sex: Bool = false //False is female, True will be male
    
    // enum of either .create or .edit
    let mode: PetFormType
    
    // closes the view with the x button
    @Environment(\.dismiss) var dismiss

    // for selecting a photo from camera roll
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem? = nil
  
    // for input validation
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // for editing a pet
    @State private var hasLoadedEditData = false
    @State private var existingPetID: String? = nil
    
    
    var body: some View {
        ZStack {
            Color.dark.ignoresSafeArea()
            VStack {
                // close and save buttons
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 30))
                            .padding()
                    }

                    Spacer()
                    Button {
                        if viewModel.isValidPetEntry(name: name, type: type, age: age, weight: weight, image: selectedImage) {
                            viewModel.saveOrUpdatePet(
                                name: name,
                                type: type,
                                age: age,
                                weight: weight,
                                note: note,
                                sex: sex,
                                image: selectedImage,
                                existingPetID: existingPetID
                            )
                            dismiss()
                        } else {
                            alertMessage = "Please fill out all fields."
                            showAlert = true
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 30))
                            .padding()
                    }
                }
                
                // Profile picture
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 160, height: 160)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.bottom, 10)
                .offset(y: -20)
                
                // select a photo from camera roll
                PhotosPicker(selection:$selectedItem,matching: .images){
                    Text("Select a photo")
                        .padding()
                        .background(Color.dark)
                        .foregroundColor(Color.lightGreen)
                        .padding(.top, -20)
                }
                .onChange(of: selectedItem) { oldValue, newValue in
                    Task {
                        if let item = newValue,
                           let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }
                
                // Name
                HStack {
                    Text("Name: ").modifier(textStyle())
                    TextField("Name", text: $name)
                }
                .foregroundStyle(Color.lightGreen)
                .padding(.leading, 20)
                
                // Type
                HStack {
                    Text("Type: ").modifier(textStyle())
                    TextField("e.g. Dog, Cat, Rabbit...", text: $type)
                }
                .foregroundStyle(Color.lightGreen)
                .padding([.top, .leading], 20)
                
                // Sex Selection
                HStack {
                    Text("Sex: ")
                        .modifier(textStyle())

                    // Male
                    Text("♂️")
                        .font(.system(size: 40))
                        .fontWeight(sex ? .bold : .regular)
                        .foregroundColor(sex ? .blue : .gray)
                        .onTapGesture {
                            sex = true
                        }

                    // Female
                    Text("♀️")
                        .font(.system(size: 40))
                        .fontWeight(!sex ? .bold : .regular)
                        .foregroundColor(!sex ? .pink : .gray)
                        .padding(.leading, 10)
                        .onTapGesture {
                            sex = false
                        }
                }
                .foregroundStyle(Color.lightGreen)
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Age
                HStack {
                    Text("Age: ").modifier(textStyle())
                    TextField("Age", text: $age)
                }
                .foregroundStyle(Color.lightGreen)
                .padding(.leading, 20)
                
                // Weight
                HStack {
                    Text("Weight: ").modifier(textStyle())
                    TextField("Weight", text: $weight)
                }
                .foregroundStyle(Color.lightGreen)
                .padding([.top, .leading], 20)
                
                // Note
                VStack(alignment: .leading) {
                    Text("Note:").modifier(textStyle())

                    TextEditor(text: $note)
                        .padding(10)
                        .frame(height: 100)
                        .scrollContentBackground(.hidden)
                        .background(Color.dark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.lightGreen, lineWidth: 1)
                        )
                        .foregroundColor(Color.lightGreen)
                }
                .foregroundStyle(Color.lightGreen)
                .padding(20)
                
                Spacer()
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                guard !hasLoadedEditData else { return }

                if case let .edit(pet) = mode {
                    name = pet.name
                    type = pet.type
                    age = pet.age
                    weight = pet.weight
                    note = pet.note
                    sex = pet.sex
                    existingPetID = pet.id
                    hasLoadedEditData = true

                    if let urlString = pet.imageURL, let url = URL(string: urlString) {
                        URLSession.shared.dataTask(with: url) { data, _, _ in
                            if let data = data, let uiImage = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    selectedImage = uiImage
                                }
                            }
                        }.resume()
                    }
                }
            }


        }
    }
}





//modifier for text when pet's name
struct titleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .bold()
            .font(.system(size: 25))
    }
}



#Preview {
    PetProfile(mode: .create)
}

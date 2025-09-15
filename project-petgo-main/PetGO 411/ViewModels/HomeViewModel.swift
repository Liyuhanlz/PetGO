import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit

class HomeViewModel: ObservableObject {
    @Published var pets: [PetModel] = []

    func fetchPets() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user signed in")
            return
        }

        Firestore.firestore()
            .collection("Users")
            .document(userID)
            .collection("pets")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching pets: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No pet documents found")
                    return
                }

                var fetchedPets: [PetModel] = []

                for doc in documents {
                    let data = doc.data()
                    let name = data["name"] as? String ?? "Unnamed"
                    let type = data["type"] as? String ?? "Unknown"
                    let age = data["age"] as? String ?? "?"
                    let imageURL = data["imageURL"] as? String
                    let weight = data["weight"] as? String ?? "?"
                    let note = data["note"] as? String ?? ""
                    let sexString = data["sex"] as? String ?? "female"
                    let sex = (sexString.lowercased() == "male")

                    let pet = PetModel(
                        id: doc.documentID,
                        name: name,
                        type: type,
                        age: age,
                        imageURL: imageURL,
                        image: nil,
                        weight: weight,
                        note: note,
                        sex: sex
                    )
                    fetchedPets.append(pet)
                }

                DispatchQueue.main.async {
                    self.pets = fetchedPets
                    self.loadPetImages()
                }
            }
    }

    private func loadPetImages() {
        for index in pets.indices {
            guard let urlString = pets[index].imageURL,
                  let url = URL(string: urlString) else {
                continue
            }

            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.pets[index].image = uiImage
                    }
                }
            }.resume()
        }
    }
    
    func deletePet(at offsets: IndexSet) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        offsets.forEach { index in
            let pet = pets[index]
            let docRef = Firestore.firestore()
                .collection("Users")
                .document(userID)
                .collection("pets")
                .document(pet.id)

            docRef.delete { error in
                if let error = error {
                    print("Error deleting pet: \(error.localizedDescription)")
                } else {
                    print("Pet deleted from Firestore")
                }
            }
        }

        pets.remove(atOffsets: offsets)
    }

}



// case of either adding a new pet entry or editing an existing entry
enum PetFormType {
    case create // a view for creation
    case edit(PetModel) // a view for editing an exisiting instance of JournalEntry
}


// each pet in the Home view
struct PetModel: Identifiable {
    let id: String
    let name: String
    let type: String
    let age: String
    let imageURL: String?
    var image: UIImage? = nil
    let weight: String
    let note: String
    let sex: Bool
}

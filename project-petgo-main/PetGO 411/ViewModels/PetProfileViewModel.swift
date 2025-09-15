
import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit

class PetProfileViewModel: ObservableObject {
    
    func saveOrUpdatePet(
        name: String,
        type: String,
        age: String,
        weight: String,
        note: String,
        sex: Bool,
        image: UIImage?,
        existingPetID: String? = nil
    ) {
        let userID = Auth.auth().currentUser!.uid

        if let image = image {
            uploadImage(image, userID: userID) { result in
                switch result {
                case .success(let imageURL):
                    if let petID = existingPetID {
                        self.updatePetInFirestore(
                            userID: userID,
                            petID: petID,
                            name: name,
                            type: type,
                            age: age,
                            weight: weight,
                            note: note,
                            sex: sex,
                            imageURL: imageURL
                        )
                    } else {
                        self.savePetToFirestore(
                            userID: userID,
                            name: name,
                            type: type,
                            age: age,
                            weight: weight,
                            note: note,
                            sex: sex,
                            imageURL: imageURL
                        )
                    }
                case .failure(let error):
                    print("Failed to upload image: \(error.localizedDescription)")
                }
            }
        } else {
            print(" No image provided. Aborting save.")
        }

    }
    
    // creates a pet and saves it
    private func savePetToFirestore(
        userID: String,
        name: String,
        type: String,
        age: String,
        weight: String,
        note: String,
        sex: Bool,
        imageURL: String
    ) {
        let petData: [String: Any] = [
            "name": name,
            "type": type,
            "age": age,
            "weight": weight,
            "note": note,
            "sex": sex ? "male" : "female",
            "imageURL": imageURL,
            "createdAt": Date().timeIntervalSince1970
        ]

        Firestore.firestore()
            .collection("Users")
            .document(userID)
            .collection("pets")
            .addDocument(data: petData) { error in
                if let error = error {
                    print("Error saving pet: \(error.localizedDescription)")
                } else {
                    print("Pet and image saved successfully!")
                }
            }
    }
    
    // updates an existing pet
    private func updatePetInFirestore(
        userID: String,
        petID: String,
        name: String,
        type: String,
        age: String,
        weight: String,
        note: String,
        sex: Bool,
        imageURL: String
    ) {
        let updatedData: [String: Any] = [
            "name": name,
            "type": type,
            "age": age,
            "weight": weight,
            "note": note,
            "sex": sex ? "male" : "female",
            "imageURL": imageURL,
            "updatedAt": Date().timeIntervalSince1970
        ]

        Firestore.firestore()
            .collection("Users")
            .document(userID)
            .collection("pets")
            .document(petID)
            .updateData(updatedData) { error in
                if let error = error {
                    print("Error updating pet: \(error.localizedDescription)")
                } else {
                    print("Pet successfully updated!")
                }
            }
    }


    // validate all fields
    func isValidPetEntry(
        name: String,
        type: String,
        age: String,
        weight: String,
        image: UIImage?
    ) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty &&
               !type.trimmingCharacters(in: .whitespaces).isEmpty &&
               !age.trimmingCharacters(in: .whitespaces).isEmpty &&
               !weight.trimmingCharacters(in: .whitespaces).isEmpty &&
               image != nil
    }
    
    
    // saves image to firebase
    private func uploadImage(_ image: UIImage, userID: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to JPEG."])))
            return
        }

        let imageID = UUID().uuidString
        let ref = Storage.storage().reference()
            .child("Users/\(userID)/pets/\(imageID).jpg")

        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                ref.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }
    
}



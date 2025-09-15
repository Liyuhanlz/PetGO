import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class JournalViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    @Published var entries: [JournalEntry] = []

    
    // saves a journal entry to firebase
    func saveEntry(title: String, date: Date, image: UIImage?) async throws {
        guard validate(title: title, image: image),
              let image = image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw SaveError.validation
        }

        let userID = Auth.auth().currentUser!.uid // safe to force unwrap, there will always be a signed in user atp
        let entryID = UUID().uuidString
        let storageRef = storage.reference().child("Users/\(userID)/journalImages/\(entryID).jpg")

        // Upload image
        _ = try await storageRef.putDataAsync(imageData, metadata: nil)

        // Get download URL
        let url = try await storageRef.downloadURL()

        // Save to Firestore under user-specific path
        let entry = JournalEntry(id: entryID, title: title, date: date, imageURL: url.absoluteString)
        try db
            .collection("Users")
            .document(userID)
            .collection("journalEntries")
            .document(entryID)
            .setData(from: entry)
    }


    // input Validation, makes sure an image an title is given
    private func validate(title: String, image: UIImage?) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && image != nil
    }
    
    // Fetch users entries from Firestore
    func fetchEntries() async {
        let userID = Auth.auth().currentUser!.uid // safe to force unwrap, there will always be a signed in user atp
        do {
            let snapshot = try await db
                .collection("Users")
                .document(userID)
                .collection("journalEntries")
                .getDocuments()

            let fetched: [JournalEntry] = try snapshot.documents.compactMap {
                try $0.data(as: JournalEntry.self)
            }

            DispatchQueue.main.async {
                self.entries = fetched.sorted { $0.date > $1.date } // recent first
            }
        } catch {
            print("Error fetching journal entries: \(error.localizedDescription)")
        }
    }

    // update an existing entry
    func updateEntry(existingEntry: JournalEntry, newTitle: String, newDate: Date, newImage: UIImage?) async throws {
        let userID = Auth.auth().currentUser!.uid
        let docRef = db
            .collection("Users")
            .document(userID)
            .collection("journalEntries")
            .document(existingEntry.id)

        var imageURL = existingEntry.imageURL

        // If a new image is selected, upload and replace the old one
        if let newImage = newImage,
           let imageData = newImage.jpegData(compressionQuality: 0.8) {

            let fileName = URL(string: existingEntry.imageURL ?? "")?.lastPathComponent ?? "\(existingEntry.id).jpg"
            let imageRef = storage.reference().child("Users/\(userID)/journalImages/\(fileName)")

            _ = try await imageRef.putDataAsync(imageData, metadata: nil)
            let url = try await imageRef.downloadURL()
            imageURL = url.absoluteString
        }

        let updatedEntry = JournalEntry(id: existingEntry.id, title: newTitle, date: newDate, imageURL: imageURL)
        try docRef.setData(from: updatedEntry)

        await fetchEntries() // Refresh local entries
    }


    // Delete an entry from Firestore + Storage
    func deleteEntry(_ entry: JournalEntry) {
        let userID = Auth.auth().currentUser!.uid // safe to force unwrap, there will always be a signed in user atp

        // Delete the Firestore doc
        db.collection("Users")
            .document(userID)
            .collection("journalEntries")
            .document(entry.id)
            .delete { error in
                if let error = error {
                    print("Error deleting document: \(error.localizedDescription)")
                } else {
                    print("Entry deleted successfully.")
                    DispatchQueue.main.async {
                        self.entries.removeAll { $0.id == entry.id }
                    }

                    // Delete image from Storage if present
                    if let url = entry.imageURL,
                       let fileName = URL(string: url)?.lastPathComponent {
                        let imageRef = self.storage
                            .reference()
                            .child("Users/\(userID)/journalImages/\(fileName)")

                        imageRef.delete { error in
                            if let error = error {
                                print("Failed to delete image: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
    }

}






// case of either adding a new journal entry or editing an existing entry
enum JournalFormType {
    case create // a view for creation
    case edit(JournalEntry) // a view for editing an exisiting instance of JournalEntry
}

// a Journal Entry
struct JournalEntry: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var date: Date
    var imageURL: String?  // Optional: we’ll use this later with Firebase Storage
}


//  error enum
enum SaveError: Error, LocalizedError {
    case validation

    var errorDescription: String? {
        switch self {
        case .validation:
            return "Please fill out all fields."
        }
    }
}

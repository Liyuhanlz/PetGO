
import SwiftUI
import UIKit
import PhotosUI

struct Journal: View {
    @StateObject var viewModel = JournalViewModel()
    
    // Navigation Purposes, binding value from NavBar file
    @State private var selectedView: ViewDestination? = .journal
    
    // shows the sheet to add a journal entry
    @State private var showSheet = false
    
    // show sheet to edit a journal entry
    @State private var entryToEdit: JournalEntry? = nil

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.dark.ignoresSafeArea()
                VStack {
                    // top part of the view
                    HStack {
                        Text("Journal")
                            .foregroundStyle(Color.lightGreen)
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        Spacer()
                        Button {
                            showSheet = true
                        } label: {
                            Image(systemName: "text.badge.plus")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.lightGreen)
                                .padding(.trailing, 20)
                        }
                    }
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                    // end of the top part of the view
                    
                    if viewModel.entries.isEmpty {
                        Text("No Journal Entries")
                            .foregroundColor(.gray)
                            .padding(.top, 100)
                            .frame(maxWidth: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.entries) { entry in
                                Button {
                                    entryToEdit = entry // when tapped, set entry to open in .edit mode
                                } label: {
                                    AnEntry(entry: entry)
                                }
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteEntry(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(Color.dark)
                        .frame(maxHeight: .infinity)
                    }

                

                               
                    // bottom navigation
                    Spacer()
                    NavBar(selectedView: $selectedView)
                } // end of main Vstack
                .navigationDestination(item: $selectedView) { view in
                    switch view {
                        case .home: Home().navigationBarBackButtonHidden(true)
                        case .journal: Journal().navigationBarBackButtonHidden(true)
                        case .profile: Profile().navigationBarBackButtonHidden(true)
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchEntries()
                    }
                }
            } // end of ZStack
            .fullScreenCover(isPresented: $showSheet, onDismiss: {
                Task {
                    await viewModel.fetchEntries()
                }
            }) {
                JournalEntryForm(viewModel: viewModel, mode: .create)
            }
            .fullScreenCover(item: $entryToEdit) { entry in
                // edit JournalEntryForm view
                JournalEntryForm(viewModel: viewModel, mode: .edit(entry))
            }
        } // end of Navigation Stack
    } // end of body
}
#Preview {
    Journal()
}



// pop up sheet to either edit or create a journal entry
struct JournalEntryForm: View {
    @ObservedObject var viewModel: JournalViewModel
    
    // enum of either .create or .edit
    let mode: JournalFormType
    
    // closes the view with the x button
    @Environment(\.dismiss) var dismiss

    // Entry data
    @State private var title: String = ""
    @State private var date: Date = Date()

    // for selection of photo from camera roll
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    // for input validation
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    var body: some View {
        VStack {
            // Close & Save buttons
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
                    Task {
                        do {
                            switch mode {
                            case .create:
                                try await viewModel.saveEntry(title: title, date: date, image: selectedImage)
                            case .edit(let entry):
                                try await viewModel.updateEntry(
                                    existingEntry: entry,
                                    newTitle: title,
                                    newDate: date,
                                    newImage: selectedImage
                                )
                            }

                            dismiss()
                        } catch {
                            validationMessage = error.localizedDescription
                            showValidationAlert = true
                        }
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 30))
                        .padding()
                }
            }
            .alert("Error", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .padding(.top, 30)

            // Image Preview and Picker, choosing from camera roll
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 280, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 280, height: 280)
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                .onChange(of: selectedItem) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }
            }
            .padding(.top, 30)
       
            // Title Entry Field
            ZStack(alignment: .center) {
                if title.isEmpty {
                    Text("Journey Entry Title")
                        .foregroundColor(.secondary)
                        .font(.title)
                        .padding(20)
                }

                TextField("", text: $title)
                    .foregroundStyle(Color.lightGreen)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(20)
            }

            // Date selection
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .foregroundColor(.gray)
                .font(.title2)
                .padding(20)

            Spacer()
        }
        .background(Color.dark)
        .ignoresSafeArea()
        .onAppear {
            if case let .edit(entry) = mode {
                // Pre-fill title and date
                self.title = entry.title
                self.date = entry.date
                
                // load image from URL
                if let urlString = entry.imageURL,
                   let url = URL(string: urlString) {
                    Task {
                        do {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            if let image = UIImage(data: data) {
                                self.selectedImage = image
                            }
                        } catch {
                            print("Failed to load image for editing: \(error)")
                        }
                    }
                }
            }
        }
    }
}


// view for each individual journal entry
struct AnEntry: View {
    let entry: JournalEntry

    var body: some View {
        HStack(spacing: 15) {
            // Load image from URL
            AsyncImage(url: URL(string: entry.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure(_):
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }

                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 120)
            .cornerRadius(10)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.title)
                    .foregroundStyle(Color.lightGreen)

                Text(formattedDate(entry.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.dark)
        .cornerRadius(12)
    }

    // Format the date nicely, better readability
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
#Preview("Entry Preview") {
    AnEntry(entry: JournalEntry(
        id: UUID().uuidString,
        title: "Walk in the Park",
        //description: "A nice stroll with my pet.",
        date: Date(),
        imageURL: "https://picsum.photos/200"
    ))
}



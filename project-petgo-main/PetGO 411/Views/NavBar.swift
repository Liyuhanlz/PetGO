import SwiftUI



// view for the bottom navigation icons used in Home, Journal, and Profile
struct NavBar: View {
    
    // gets updated based on the clicked icon, this enum is defined in the Model file
    @Binding var selectedView: ViewDestination?

    var body: some View {
        VStack {
            Divider()
                .frame(height: 2)
                .background(Color.gray)

            HStack {
                navItem("house", "house.fill", "Home", .home)
                navItem("book.pages", "book.pages.fill", "Journal", .journal)
                navItem("person", "person.fill", "Profile", .profile)
            }
            .padding(.vertical, 10)
            .foregroundColor(Color.lightGreen)
        }
    }
    
    // this function returns a view, used as the template for the icons in the bottom of the page
    @ViewBuilder
    private func navItem(_ icon: String, _ filledIcon: String, _ label: String, _ view: ViewDestination) -> some View {
        Spacer()
        VStack {
            Image(systemName: selectedView == view ? filledIcon : icon)
                .resizable()
                .frame(width: 24, height: 24)
                .onTapGesture { selectedView = view }
            Text(label)
                .font(.caption)
                .underline()
                .bold()
                .opacity(selectedView == view ? 1 : 0) // bold and underline are transparent if not selected,
                                                       // this way does not move the other elements
        }
        Spacer()
    }
}





/*
 Notes:
     @ViewBuilder:
         - Combines Multiple Views into one, lets you write multiple views (Text, VStack, Spacer) inside a function or computed property, and it automatically combines them into a single view to satisfy the some View return type.

         - Eliminates the Need for return, you don’t need to write a return statement, Swift collects all the view expressions and bundles them for you.

         - Compiles to a Single View Type, under the hood, it turns your block of views into a single TupleView, Group, or similar SwiftUI container so the view system can display it properly.
 
     @Binding:
        - Creates a Two-Way Connection to Data, lets a child view read and write to a piece of state owned by a parent view. It’s a reference, not a copy, so changes reflect both ways.

        - Used for Data Flow from Parent to Child, when you want a child view to control or modify a parent’s state without owning it, you pass a @Binding instead of a normal value.

        - Syntax: Use $ Prefix to Pass Bindings, in the parent view, you pass a binding using the $ operator (e.g., $selectedView) to link the state to the child’s @Binding property.

 */

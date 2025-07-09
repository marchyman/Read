//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct NewAuthorView: View {
    @Environment(Store<BookState, ModelAction>.self) var store
    @Environment(\.dismiss) var dismiss
    @State private var author: Author = Author(lastName: "")

    var selectedAuthor: Binding<String>?

    enum FocusableFields: Hashable {
        case lastName
        case firstName
    }

    @FocusState private var focusedField: FocusableFields?

    var body: some View {
        VStack(alignment: .leading) {
            CancelOrAddView(
                addText: "Add New Author",
                addFunc: addAuthor,
                disabled: invalidAuthor)
            Form {
                TextField("First name", text: $author.firstName)
                    .focused($focusedField, equals: .firstName)
                    .onSubmit { focusedField = .lastName }

                TextField("Last name", text: $author.lastName)
                    .focused($focusedField, equals: .lastName)
                    .onSubmit { focusedField = .firstName }
            }
            .cornerRadius(8)
            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = .firstName
        }
    }

    func invalidAuthor() -> Bool {
        guard !author.lastName.isEmpty else { return true }
        let match = store.authors.first(where: { $0.name == author.name })
        return match != nil
    }

    func addAuthor() {
        store.send(.addAuthorButton(author))
        selectedAuthor?.wrappedValue = author.name
        dismiss()
    }
}

#Preview {
    NewAuthorView(selectedAuthor: .constant("none"))
        .environment(Store(initialState: BookState(forPreview: true,
                                                   addTestData: true),
                           reduce: ModelReducer()))
}

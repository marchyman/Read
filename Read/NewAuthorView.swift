//
//  NewAuthorView.swift
//  Read
//
//  Created by Marco S Hyman on 1/31/24.
//

import SwiftData
import SwiftUI

struct NewAuthorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query private var authors: [Author]
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
        let match = authors.first(where: { $0.name == author.name })
        return match != nil
    }

    func addAuthor() {
        context.insert(author)
        do {
            try context.save()
        } catch {
            fatalError("NewAuthorView context.save")
        }
        selectedAuthor?.wrappedValue = author.name
        dismiss()
    }
}

#Preview {
    NewAuthorView(selectedAuthor: .constant("none"))
        .modelContainer(Book.preview)
}

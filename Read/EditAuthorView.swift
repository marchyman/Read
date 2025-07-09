//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct EditAuthorView: View {
    @Environment(Store<BookState, ModelAction>.self) var store
    @Environment(\.dismiss) private var dismiss

    var author: Author

    @State private var firstName: String = ""
    @State private var lastName: String = ""

    enum FocusableFields: Hashable {
        case lastName
        case firstName
    }

    @FocusState private var focusedField: FocusableFields?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button {
                    if author.firstName != firstName || author.lastName != lastName {
                        store.send(.editAuthorDone(author, firstName, lastName))
                    }
                    dismiss()
                } label: {
                    Text("done")
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .disabled(doneDisabled())
            }
            Form {
                TextField("First name", text: $firstName)
                    .focused($focusedField, equals: .firstName)
                    .onSubmit { focusedField = .lastName }

                TextField("Last name", text: $lastName)
                    .focused($focusedField, equals: .lastName)
                    .onSubmit { focusedField = .firstName }
            }
            .cornerRadius(8)
            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = .firstName
            firstName = author.firstName
            lastName = author.lastName
        }
    }

    private func doneDisabled() -> Bool {
        author.firstName.isEmpty && author.lastName.isEmpty
    }
}

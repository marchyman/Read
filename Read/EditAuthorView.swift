//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import SwiftData
import SwiftUI

struct EditAuthorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    enum FocusableFields: Hashable {
        case lastName
        case firstName
    }

    @FocusState private var focusedField: FocusableFields?

    @Bindable var author: Author

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("done")
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .disabled(doneDisabled())
            }
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

    private func doneDisabled() -> Bool {
        author.firstName.isEmpty && author.lastName.isEmpty
    }
}

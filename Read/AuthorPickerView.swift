//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

private let addAuthor = "Add new author"
private let pickAuthor = "Select author(s)"

struct AuthorPickerView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store

    var selectEvent: (Author) -> Void

    @State private var selectedAuthor = pickAuthor
    @State private var newAuthor = false

    var body: some View {
        HStack {
            Picker(selection: $selectedAuthor) {
                Text(pickAuthor)
                    .tag(pickAuthor)
                Text(addAuthor)
                    .tag(addAuthor)
                ForEach(store.authors) {
                    Text($0.name)
                        .tag($0.name)
                }
            } label: {
                Text("Select author from list: ")
                    .font(.headline)
            }
            .pickerStyle(.menu)
            .frame(width: 350)
            .onChange(of: selectedAuthor) {
                if selectedAuthor == addAuthor {
                    newAuthor.toggle()
                } else {
                    if let author = store.authors.first(where: {
                        $0.name == selectedAuthor
                    }) {
                        selectEvent(author)
                    }
                    selectedAuthor = pickAuthor
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $newAuthor) {
            NewAuthorView(selectedAuthor: $selectedAuthor)
        }
    }
}

#Preview {
    Form {
        Section("Authors") {
            AuthorPickerView(selectEvent: { _ in })
                .environment(Store(initialState: BookState(forPreview: true,
                                                           addTestData: true),
                                   reduce: ModelReducer()))
        }
    }
}

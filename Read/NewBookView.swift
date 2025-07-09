//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct NewBookView: View {
    @Environment(Store<BookState, ModelAction>.self) var store
    @Environment(\.dismiss) var dismiss

    // create state variables for each field of a book, author, and series.
    // A new book will be created from this state when the user selects the
    // add button.
    @State private var title: String = ""
    @State private var selectedAuthors: [Author] = []
    @State private var seriesName: String = ""
    @State private var seriesOrder: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            CancelOrAddView(
                addText: "Add New Book",
                addFunc: addBook,
                disabled: { title.isEmpty })

            BookFormView(title: $title, selectedAuthors: $selectedAuthors,
                         seriesName: $seriesName, seriesOrder: $seriesOrder)
        }
        .padding()
    }

    func addBook() {
        let book = Book(title: title)
        store.send(.addBookButton(book))
        store.send(.bookUpdateOrAddButton(book, title, selectedAuthors,
                                          seriesName, seriesOrder))
        dismiss()
    }
}

#Preview {
    NewBookView()
        .environment(Store(initialState: BookState(forPreview: true,
                                                   addTestData: true),
                           reduce: ModelReducer()))
}

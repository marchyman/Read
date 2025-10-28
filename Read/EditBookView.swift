//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct EditBookView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store

    var book: Book
    var updated: () -> Void     // function called after update to
                                // return to the previous view

    // create state variables for each field of a book, author, and series.
    // Initial values will be set from the above book when the view appears
    // and written back to the book when the update button is pressed.
    @State private var title: String = ""
    @State private var selectedAuthors: [Author] = []
    @State private var seriesName: String = ""
    @State private var seriesOrder: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            BookFormView(title: $title, selectedAuthors: $selectedAuthors,
                         seriesName: $seriesName, seriesOrder: $seriesOrder)
            Spacer()
        }
        .padding()
        .onAppear {
            setInitialState()
        }
        .navigationTitle("Edit book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                store.send(.bookUpdateOrAddButton(book, title, selectedAuthors,
                                                  seriesName, seriesOrder))
                updated()
            } label: {
                Text("Update Book")
            }
            .buttonStyle(.bordered)
            .disabled(updatesDisabled())
        }
    }
}

extension EditBookView {
    private func setInitialState() {
        // initialize fields from an existing book
        title = book.title
        selectedAuthors = book.authors
        if let series = book.series {
            seriesName = series.name
            seriesOrder = book.seriesOrder ?? 0
        } else {
            seriesName = ""
            seriesOrder = 0
        }
    }

    private func updatesDisabled() -> Bool {
        if book.title != title { return false }
        if book.authors != selectedAuthors { return false }
        if let series = book.series {
            if series.name != seriesName { return false }
        } else {
            if seriesName != "" { return false }
        }
        if book.series != nil && book.seriesOrder != seriesOrder { return false }
        return true
    }
}

#Preview {
    let store = Store(initialState: BookState(forPreview: true,
                                              addTestData: true),
                      reduce: ModelReducer())

    NavigationStack {
        EditBookView(book: store.books[0], updated: {})
            .environment(store)
    }
}

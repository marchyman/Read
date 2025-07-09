//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct BooksByTitleView: View {
    @Environment(Store<BookState, ModelAction>.self) var store
    @State private var newBook = false
    @State private var updater = false

    let search: String

    var body: some View {
        let books = store.books.filter {
            search.isEmpty ? true
                           : $0.title.localizedStandardContains(search)
        }
        VStack(alignment: .leading) {
            if books.isEmpty {
                ContentUnavailableView {
                    Label("Books by Title", systemImage: "book.closed")
                } description: {
                    Text("No Books found.")
                    if !search.isEmpty {
                        Text("Check your search string")
                    }
                }
            } else {
                List {
                    ForEach(books) { book in
                        NavigationLink(value: book) {
                            BookTitleView(book: book)
                        }
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            for index in indexSet {
                                store.send(.onBookDelete(books[index]))
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .id(updater)
            }
        }
        .padding(.horizontal)
        .contentMargins(.horizontal, 40, for: .scrollContent)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Books")
                    .font(.title2).bold()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    newBook = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $newBook) {
            NewBookView()
        }
        .onChange(of: store.state) {
            // otherwise the list may not know the data that makes up
            // BookTitleView changed.
            updater.toggle()
        }
    }
}

#Preview {
    NavigationStack {
        BooksByTitleView(search: "")
            .environment(Store(initialState: BookState(forPreview: true,
                                                       addTestData: true),
                               reduce: ModelReducer()))
            .navigationTitle("Books")
    }
}

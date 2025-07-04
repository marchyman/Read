//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftData
import SwiftUI
import UDF

struct BooksByTitleView: View {
    @Environment(Store<BookState, ModelAction>.self) var store
    @State private var newBook = false

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
            }
        }
        .padding(.horizontal)
        .contentMargins(.horizontal, 40, for: .scrollContent)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Books")
                    .font(.title2).bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
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

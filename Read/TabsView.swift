//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct TabsView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store
    @State private var searchText = ""
    @State private var path = NavigationPath()

    var body: some View {
        TabView {
            Tab("Titles", systemImage: "book.closed") {
                NavigationStack(path: $path) {
                    BooksByTitleView(search: searchText)
                        .searchable(text: $searchText, prompt: "Title search")
                        .navigationDestination(for: Book.self) { book in
                            EditBookView(book: book) {
                                path.removeLast()
                            }
                        }
                }
            }

            Tab("Authors", systemImage: "character.book.closed") {
                NavigationStack(path: $path) {
                    BooksByAuthorView(search: searchText)
                        .searchable(text: $searchText, prompt: "Author search")
                        .navigationDestination(for: Book.self) { book in
                            EditBookView(book: book) {
                                path.removeLast()
                            }
                        }
                }
            }

            Tab("Series", systemImage: "books.vertical") {
                NavigationStack(path: $path) {
                    BooksBySeriesView(search: searchText)
                        .searchable(text: $searchText, prompt: "Series search")
                        .navigationDestination(for: Book.self) { book in
                            EditBookView(book: book) {
                                path.removeLast()
                            }
                        }
                }
            }
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    TabsView()
        .environment(Store(initialState: BookState(forPreview: true,
                                                   addTestData: true),
                           reduce: ModelReducer()))
}

//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var path = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack(path: $path) {
                BooksByTitleView(search: searchText)
                    .searchable(text: $searchText, prompt: "Title search")
                    .navigationDestination(for: Book.self) { book in
                        EditBookView(book: book) {
                            path.removeLast()
                        }
                    }
            }
            .tabItem {
                Label("Titles", systemImage: "book.closed")
            }

            NavigationStack(path: $path) {
                BooksByAuthorView(search: searchText)
                    .searchable(text: $searchText, prompt: "Author search")
                    .navigationDestination(for: Book.self) { book in
                        EditBookView(book: book) {
                            path.removeLast()
                        }
                    }
            }
            .tabItem {
                Label("Authors", systemImage: "character.book.closed")
            }

            NavigationStack(path: $path) {
                BooksBySeriesView(search: searchText)
                    .searchable(text: $searchText, prompt: "Series search")
                    .navigationDestination(for: Book.self) { book in
                        EditBookView(book: book) {
                            path.removeLast()
                        }
                    }
            }
            .tabItem {
                Label("Series", systemImage: "books.vertical")
            }
        }
    }
}

#Preview {
    ContentView()
}

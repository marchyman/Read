//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct ContentView: View {
    @Environment(Store<BookState, ModelAction>.self) var store
    @State private var searchText = ""
    @State private var path = NavigationPath()
    @State private var errorAlert = false
    @State private var showLog = false

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
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showLog.toggle()
                } label: {
                    Text("""
                        ^[\(store.books.count) Book](inflect: true), \
                        ^[\(store.authors.count) Author](inflect: true), \
                        ^[\(store.series.count) Series](inflect: true)
                        """)
                }
            }
        }
        .onChange(of: store.lastError) {
            if store.lastError != nil {
                errorAlert.toggle()
            }
        }
        .sheet(isPresented: $showLog) { LogView() }
        .alert("Something unexpected happened", isPresented: $errorAlert) {
            // system provides a button to dismiss
        } message: {
            Text("""
                Error text:

                \(store.lastError ?? "unknown error")
                """)
        }
    }
}

#Preview {
    ContentView()
        .environment(Store(initialState: BookState(forPreview: true,
                                                   addTestData: true),
                           reduce: ModelReducer()))
}

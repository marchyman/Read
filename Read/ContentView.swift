//
//  ContentView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var searchText = ""
    @State private var path = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack(path: $path) {
                BooksByTitleView(search: searchText)
                    .navigationTitle("Books")
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

            NavigationStack {
                BooksByAuthorView(search: searchText)
                    .navigationTitle("Authors")
                    .searchable(text: $searchText, prompt: "Author search")
            }
            .tabItem {
                Label("Authors", systemImage: "character.book.closed")
            }

            NavigationStack {
                BooksBySeriesView(search: searchText)
                    .navigationTitle("Series Name")
                    .searchable(text: $searchText, prompt: "Series search")
            }
            .tabItem {
                Label("Series", systemImage: "books.vertical")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(Book.preview)
}

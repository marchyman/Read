//
//  ContentView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var newBook = false
    @State private var searchText = ""

    var body: some View {
        TabView {
            NavigationStack {
                BooksByTitleView(search: searchText)
                    .navigationTitle("Books")
                    .searchable(text: $searchText, prompt: "Title search")
                    .toolbar {
                        Button("Add Book", systemImage: "plus",
                               action: { newBook = true })
                    }
                    .navigationDestination(for: Book.self) { book in
                        BookDetailView(book: book)
                    }
            }
            .tabItem {
                Label("Titles", systemImage: "book.closed")
            }

            NavigationStack {
                BooksByAuthorView()
                    .navigationTitle("Authors")
                    .searchable(text: $searchText, prompt: "Author search")
            }
            .tabItem {
                Label("Authors", systemImage: "character.book.closed")
            }

            NavigationStack {
                BooksBySeriesView()
                    .navigationTitle("Series")
                    .searchable(text: $searchText, prompt: "Series search")
            }
            .tabItem {
                Label("Series", systemImage: "books.vertical")
            }
        }
        .sheet(isPresented: $newBook) {
            NewBookView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}

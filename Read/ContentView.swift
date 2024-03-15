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

    var body: some View {
        TabView {
            NavigationStack {
                BooksByTitleView(search: searchText)
                    .navigationTitle("Book Titles")
                    .searchable(text: $searchText, prompt: "Title search")
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

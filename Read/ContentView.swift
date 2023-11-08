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
    @State private var sortOrder = SortDescriptor(\Book.series)
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            BookListView(sort: sortOrder, search: searchText)
                .navigationTitle("Books")
                .searchable(text: $searchText)
                .toolbar {
                    Button("Add Book", systemImage: "plus",
                           action: { newBook = true })
                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
                        Picker("Sort", selection: $sortOrder) {
                            Text("Title")
                                .tag(SortDescriptor(\Book.title))
                            Text("Series")
                                .tag(SortDescriptor(\Book.series))
                            Text("Author")
                                .tag(SortDescriptor(\Book.author))
                        }
                        .pickerStyle(.inline)
                    }

                }
                .sheet(isPresented: $newBook) {
                    NewBookView()
                        .presentationDetents([.medium])
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}

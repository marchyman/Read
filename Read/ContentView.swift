//
//  ContentView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftUI
import SwiftData

enum SortOrder: String, Identifiable, CaseIterable {
    case series, title, author

    var id: Self {
        self
    }
}

struct ContentView: View {
    @State private var newBook = false
    @State private var sortOrder = SortOrder.series
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
                            ForEach(SortOrder.allCases) { sortOrder in
                                Text("Sort by \(sortOrder.rawValue)").tag(sortOrder)
                            }
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

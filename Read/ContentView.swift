//
//  ContentView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    @State private var newBook = false
    @State private var showPopOver = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.title).font(.title2)
                            Text(book.authorString)                            .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            if let series = book.series {
                                let order = book.seriesOrder ?? 0
                                Text("\(series) No. \(order)")
                            }
                            if let estRelease = book.estRelease {
                                Text("Est Release Date: \(estRelease .formatted(date: .numeric, time: .omitted))")
                                    .foregroundStyle(.secondary)
                                    .onTapGesture {
                                        showPopOver.toggle()
                                    }
                                    .popover(isPresented: $showPopOver) {
                                        BookReleasedView(book: book)
                                            .padding(30)
                                    }
                            } else {
                                Text("")
                            }
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        newBook = true
                    } label: {
                        Label("Add Book", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $newBook) {
                NewBookView()
                    .presentationDetents([.medium])
            }
        }
    }

    private func deleteBooks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(books[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}

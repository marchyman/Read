//
//  BooksByTitleView.swift
//  Read
//
//  Created by Marco S Hyman on 1/29/24.
//

import SwiftData
import SwiftUI

struct BooksByTitleView: View {
    @Environment(\.modelContext) private var context
    @Query private var books: [Book]
    @State private var newBook = false

    init(search: String) {
        let sortDescriptors: [SortDescriptor<Book>] = [ .init(\.title) ]
        let predicate = #Predicate<Book> { book in
            if search.isEmpty {
                return true
            } else {
                return book.title.localizedStandardContains(search)
            }
        }
        _books = Query(filter: predicate, sort: sortDescriptors)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if books.isEmpty {
                ContentUnavailableView {
                    Label("Books by Title", systemImage: "book.closed")
                } description: {
                    Text("No Books found. Check your search string")
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
                                context.delete(books[index])
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
                    Text("Add book")
                }
                .buttonStyle(.bordered)
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
            .modelContainer(Book.preview)
            .navigationTitle("Books")
    }
}

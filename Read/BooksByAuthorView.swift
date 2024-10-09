//
//  BooksByAuthorView.swift
//  Read
//
//  Created by Marco S Hyman on 1/29/24.
//

import SwiftData
import SwiftUI

struct BooksByAuthorView: View {
    @Environment(\.modelContext) private var context
    @Query private var authors: [Author]
    @State private var newBook = false
    @State private var newAuthor = false
    @State private var editAuthor: Author? = nil

    let searchActive: Bool

    init(search: String) {
        searchActive = !search.isEmpty
        let sortDescriptors: [SortDescriptor<Author>] = [
            .init(\.lastName),
            .init(\.firstName) ]
        let predicate = #Predicate<Author> { author in
            if search.isEmpty {
                return true
            } else {
                return author.lastName.localizedStandardContains(search)
                    || author.firstName.localizedStandardContains(search)
            }
        }
        _authors = Query(filter: predicate, sort: sortDescriptors)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if authors.isEmpty {
                ContentUnavailableView {
                    Label("Books by Author", systemImage: "character.book.closed")
                } description: {
                    Text("No Authors found.")
                    if searchActive {
                        Text("Check your search string")
                    }
                }
            } else {
                List {
                    ForEach(authors) {item in
                        DisclosureGroup(authorAndBookCount(author: item)) {
                            if item.books.isEmpty {
                                Text("There are no book by this author (swipe left to delete).")
                                    .italic()
                            } else {
                                ForEach(booksByTitle(item.books)) { book in
                                    BookTitleView(book: book)
                                }
                            }
                        }
                        .onLongPressGesture {
                            editAuthor = item
                        }
                        .sheet(item: $editAuthor) { item in
                            EditAuthorView(author: item)
                        }
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            for index in indexSet {
                                context.delete(authors[index])
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
                Text("Authors")
                    .font(.title2).bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    newAuthor = true
                } label: {
                    Text("Add Author")
                }
                .buttonStyle(.bordered)
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
        .sheet(isPresented: $newAuthor) {
            NewAuthorView()
        }
    }

    func authorAndBookCount(author: Author) -> LocalizedStringKey {
        var name = "\(author.firstName) **\(author.lastName)**  --  "
        // doesn't look like ^[\(count) book](inflect: true) works here.
        switch author.books.count {
        case 0:
            name.append(" *no books*")
        case 1:
            name.append(" *1 book*")
        case let count where count > 1:
            name.append(" *\(count) books*")
        default:
            break
        }
        return LocalizedStringKey(name)
    }

    func booksByTitle(_ books: [Book]?) -> [Book] {
        guard let books else { return [] }
        let descriptors: [SortDescriptor<Book>] = [ .init(\.title) ]
        return books.sorted(using: descriptors)
    }
}

#Preview {
    NavigationStack() {
        BooksByAuthorView(search: "")
            .modelContainer(Book.preview)
            .navigationTitle("Authors")
    }
}

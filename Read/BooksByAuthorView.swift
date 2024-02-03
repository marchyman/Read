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
    @Query private var author: [Author]
    @State private var newAuthor = false

    init(search: String) {
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
        _author = Query(filter: predicate, sort: sortDescriptors)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if author.isEmpty {
                ContentUnavailableView {
                    Label("Books by Author", systemImage: "character.book.closed")
                } description: {
                    Text("No Authors found.  Check your search string")
                }
            } else {
                List {
                    ForEach(author) {item in
                        DisclosureGroup("\(item.firstName) \(item.lastName)") {
                            if item.books.isEmpty {
                                Text("There are no book by this author (swipe left to delete).")
                                    .italic()
                            } else {
                                ForEach(booksByTitle(item.books)) { book in
                                    BookTitleView(book: book)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            for index in indexSet {
                                context.delete(author[index])
                            }
                        }
                    }
                }
            }
            Button("Add Author", systemImage: "plus",
                   action: { newAuthor = true })
                .font(.title)
                .buttonStyle(.bordered)
                .padding()
        }
        .sheet(isPresented: $newAuthor) {
            NewAuthorView()
        }
    }

    func booksByTitle(_ books: [Book]?) -> [Book] {
        guard let books else { return [] }
        let descriptors: [SortDescriptor<Book>] = [ .init(\.title) ]
        return books.sorted(using: descriptors)
    }
}

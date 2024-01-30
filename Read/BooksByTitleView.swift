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
        List() {
            ForEach(books) { book in
                VStack {
                    NavigationLink(book.title, value: book).font(.title2)
                }
            }
        }
    }
}

#Preview {
    BooksByTitleView(search: "")
}

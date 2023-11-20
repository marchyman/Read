//
//  BookListView.swift
//  Read
//
//  Created by Marco S Hyman on 11/7/23.
//

import SwiftUI
import SwiftData

struct BookListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    @State private var editBook: Book?
    @State private var lastInSeries = false

    init(sort: SortOrder, search: String) {
        let sortDescriptors: [SortDescriptor<Book>] = switch sort {
        case .series:
            [.init(\.series), .init(\.seriesOrder, order: .reverse)]
        case .title:
            [.init(\.title), .init(\.sortAuthor)]
        case .author:
            [.init(\.sortAuthor), .init(\.series), .init(\.seriesOrder, order: .reverse)]
        }
        let predicate = #Predicate<Book> { book in
            if search.isEmpty {
                return true
            } else {
                if let series = book.series {
                    return book.title.localizedStandardContains(search) ||
                    book.author.localizedStandardContains(search) ||
                    series.localizedStandardContains(search)
                } else {
                    return book.title.localizedStandardContains(search) ||
                    book.author.localizedStandardContains(search)
                }
            }
        }
        _books = Query(filter: predicate, sort: sortDescriptors)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(books, id: \.self) { book in
                    if !lastInSeries || lastInSeries(book) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title).font(.title2)
                                Text(book.author)
                                    .foregroundStyle(.secondary)
                            }
                            .onTapGesture {
                                editBook = book
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                if let series = book.series {
                                    let order = book.seriesOrder ?? 0
                                    Text("\(series) No. \(order)")
                                        .bold(lastInSeries)
                                        .onTapGesture {
                                            lastInSeries.toggle()
                                            proxy.scrollTo(book.added)
                                        }
                                }
                                if let estRelease = book.estRelease {
                                    Text("Est Release Date: \(estRelease .formatted(date: .numeric, time: .omitted))")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("")
                                }
                            }
                        }
                        .sheet(item: $editBook) { book in
                            EditBookView(book: book)
                                .presentationDetents([.medium])
                        }
                        .id(book.added)
                    }
                }
                .onDelete(perform: deleteBooks)
            }
        }
    }

    // return true if this is the only book or the last book in a series
    private func lastInSeries(_ book: Book) -> Bool {
        if let series = book.series,
           let order = book.seriesOrder {
            if books.contains(where: { series == $0.series &&
                                       order < ($0.seriesOrder ?? 0) }) {
                return false
            }
        }
        return true
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
    NavigationStack {
        BookListView(sort: SortOrder.title, search: "")
            .modelContainer(for: Book.self, inMemory: true)
            .navigationTitle("Books")
    }
}

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
    @State private var releasePopover = false
    @State private var lastInSeries = false

    init(sort: SortDescriptor<Book>, search: String) {
        _books = Query(
            filter: #Predicate { book in
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
            },
            sort: [sort, SortDescriptor(\.seriesOrder, order: .reverse)]
        )
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(books) { book in
                    if !lastInSeries || lastInSeries(book) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title).font(.title2)
                                Text(book.author)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                if let series = book.series {
                                    let order = book.seriesOrder ?? 0
                                    Text("\(series) No. \(order)")
                                        .onTapGesture {
                                            lastInSeries.toggle()
                                            proxy.scrollTo(book.title)
                                        }
                                        .bold(lastInSeries)
                                }
                                if let estRelease = book.estRelease {
                                    Text("Est Release Date: \(estRelease .formatted(date: .numeric, time: .omitted))")
                                        .foregroundStyle(.secondary)
                                        .onTapGesture {
                                            releasePopover.toggle()
                                        }
                                        .popover(isPresented: $releasePopover) {
                                            BookReleasedView(book: book)
                                                .padding(30)
                                        }
                                } else {
                                    Text("")
                                }
                            }
                        }
                        .id(book.title)
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
    BookListView(sort: SortDescriptor(\Book.title), search: "")
        .modelContainer(for: Book.self, inMemory: true)
}

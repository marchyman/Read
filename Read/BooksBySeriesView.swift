//
//  BooksBySeriesView.swift
//  Read
//
//  Created by Marco S Hyman on 1/29/24.
//

import SwiftData
import SwiftUI

struct BooksBySeriesView: View {
    @Environment(\.modelContext) private var context
    @Query private var series: [Series]
    @State private var newSeries = false

    init(search: String) {
        let sortDescriptors: [SortDescriptor<Series>] = [ .init(\.name) ]
        let predicate = #Predicate<Series> { series in
            if search.isEmpty {
                return true
            } else {
                return series.name.localizedStandardContains(search)
            }
        }
        _series = Query(filter: predicate, sort: sortDescriptors)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if series.isEmpty {
                ContentUnavailableView {
                    Label("Books by Series", systemImage: "books.vertical")
                } description: {
                    Text("No Series found. Check your search string")
                }
            } else {
                List {
                    ForEach(series) {item in
                        DisclosureGroup(item.name) {
                            if item.books.isEmpty {
                                Text("There are no books in this series (swipe left to delete).")
                                    .italic()
                            } else {
                                ForEach(booksBySeriesOrder(item.books)) { book in
                                    BookTitleView(book: book)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            for index in indexSet {
                                context.delete(series[index])
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            Button("Add Series", systemImage: "plus",
                   action: { newSeries = true })
                .font(.title)
                .buttonStyle(.bordered)
                .padding()
        }
        .sheet(isPresented: $newSeries) {
            NewSeriesView()
        }
    }

    func booksBySeriesOrder(_ books: [Book]?) -> [Book] {
        guard let books else { return [] }
        let descriptors: [SortDescriptor<Book>] = [ .init(\.seriesOrder) ]
        return books.sorted(using: descriptors)
    }
}

#Preview {
    BooksBySeriesView(search: "")
        .modelContainer(Book.preview)
}

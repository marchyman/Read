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
    @State private var newBook = false
    @State private var newAuthor = false
    @State private var newSeries = false
    @State private var editSeries: Series?

    let searchActive: Bool

    init(search: String) {
        searchActive = !search.isEmpty
        let sortDescriptors: [SortDescriptor<Series>] = [.init(\.name)]
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
                    Text("No Series found.")
                    if searchActive {
                        Text("Check your search string")
                    }
                }
            } else {
                List {
                    ForEach(series) { item in
                        @Bindable var item = item
                        DisclosureGroup(item.name, isExpanded: j$item.expanded) {
                            if item.books.isEmpty {
                                Text(
                                    """
                                    There are no books in this series \
                                    (swipe left to delete).
                                    """
                                )
                                .italic()
                            } else {
                                ForEach(booksBySeriesOrder(item.books)) { book in
                                    BookTitleView(book: book)
                                }
                            }
                        }
                        .onTapGesture {
                            item.expanded.toggle()
                        }
                        .onLongPressGesture {
                            editSeries = item
                        }
                        .sheet(item: $editSeries) { item in
                            EditSeriesView(series: item)
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
        }
        .padding(.horizontal)
        .contentMargins(.horizontal, 40, for: .scrollContent)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Series")
                    .font(.title2).bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    newSeries = true
                } label: {
                    Text("Add Series")
                }
                .buttonStyle(.bordered)
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
        .sheet(isPresented: $newSeries) {
            NewSeriesView()
        }
    }

    func booksBySeriesOrder(_ books: [Book]?) -> [Book] {
        guard let books else { return [] }
        let descriptors: [SortDescriptor<Book>] = [
            .init(\.seriesOrder, order: .reverse)
        ]
        return books.sorted(using: descriptors)
    }
}

#Preview {
    BooksBySeriesView(search: "")
        .modelContainer(Book.preview)
}

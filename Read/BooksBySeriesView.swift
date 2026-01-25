//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct BooksBySeriesView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store

    @State private var newBook = false
    @State private var editSeries: Series?
    @State private var search = ""

    var body: some View {
        let series = store.series.filter {
            search.isEmpty ? true
                           : $0.name.localizedStandardContains(search)
        }
        VStack(alignment: .leading) {
            if series.isEmpty {
                ContentUnavailableView {
                    Label("Books by Series", systemImage: "books.vertical")
                } description: {
                    Text("No Series found.")
                    if !search.isEmpty {
                        Text("Check your search string")
                    }
                }
            } else {
                Text("Books by Series")
                    .font(.title)
                List {
                    ForEach(series) { item in
                        @Bindable var item = item
                        DisclosureGroup(item.name, isExpanded: $item.expanded) {
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
                                    NavigationLink(value: book) {
                                        BookTitleView(book: book)
                                    }
                                }
                                .deleteDisabled(true)
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                item.expanded.toggle()
                            }
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
                                store.send(.onSeriesDelete(series[index]))
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    newBook = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $newBook) {
            NewBookView()
        }
        .searchable(text: $search, placement: .navigationBarDrawer, prompt: "Series search")
    }
}

extension BooksBySeriesView {
    func booksBySeriesOrder(_ books: [Book]?) -> [Book] {
        guard let books else { return [] }
        let descriptors: [SortDescriptor<Book>] = [
            .init(\.seriesOrder, order: .reverse)
        ]
        return books.sorted(using: descriptors)
    }
}

#Preview {
    NavigationStack {
        BooksBySeriesView()
            .environment(Store(initialState: BookState(forPreview: true,
                                                       addTestData: true),
                               reduce: ModelReducer()))
            .navigationTitle("Authors")
    }
}

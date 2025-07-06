//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import SwiftData
import SwiftUI
import UDF

struct BooksByAuthorView: View {
    @Environment(Store<BookState, ModelAction>.self) var store

    @State private var newBook = false
    @State private var editAuthor: Author?

    let search: String

    var body: some View {
        let authors = store.authors.filter {
            search.isEmpty ? true
                           : $0.name.localizedStandardContains(search)
        }
        VStack(alignment: .leading) {
            if authors.isEmpty {
                ContentUnavailableView {
                    Label("Books by Author", systemImage: "character.book.closed")
                } description: {
                    Text("No Authors found.")
                    if !search.isEmpty {
                        Text("Check your search string")
                    }
                }
            } else {
                List {
                    ForEach(authors) { item in
                        @Bindable var item = item
                        DisclosureGroup(authorAndBookCount(author: item),
                                        isExpanded: $item.expanded) {
                            if item.books.isEmpty {
                                Text("""
                                    There are no books by this author \
                                    (swipe left to delete).
                                    """)
                                .italic()
                            } else {
                                ForEach(booksByTitle(item.books)) { book in
                                    NavigationLink(value: book) {
                                        BookTitleView(book: book)
                                    }
                                }
                                .deleteDisabled(true)
                            }
                        }
                        .onLongPressGesture {
                            editAuthor = item
                        }
                        .onTapGesture {
                            withAnimation {
                                item.expanded.toggle()
                            }
                        }
                        .sheet(item: $editAuthor) { item in
                            EditAuthorView(author: item)
                        }
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            for index in indexSet {
                                store.send(.onAuthorDelete(authors[index]))
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
                    newBook = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $newBook) {
            NewBookView()
        }
    }
}

extension BooksByAuthorView {

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
        let descriptors: [SortDescriptor<Book>] = [.init(\.title)]
        return books.sorted(using: descriptors)
    }
}

#Preview {
    NavigationStack {
        BooksByAuthorView(search: "")
            .environment(Store(initialState: BookState(forPreview: true,
                                                       addTestData: true),
                               reduce: ModelReducer()))
            .navigationTitle("Authors")
    }
}

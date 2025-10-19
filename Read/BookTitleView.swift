//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

struct BookTitleView: View {
    var book: Book

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(book.title).font(.title2)
                Spacer()
                if let series = book.series {
                    Text("\(series.name) [#\(book.seriesOrder ?? 0)]")
                        .padding(.trailing)
                }
            }
            HStack(alignment: .top) {
                ForEach(book.authors) { author in
                    Text(author.name)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading)
                Spacer()
                Text("\(book.added.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundStyle(.tertiary)
                    .padding(.trailing)
            }
        }
        .padding(.horizontal, 5)
    }
}

import UDF  // only needed for preview

#Preview {

    let store = Store(initialState: BookState(forPreview: true,
                                              addTestData: true),
                      reduce: ModelReducer())

    // Does not work if I use List(store.books) or ForEach(store.books)?

    List {
        BookTitleView(book: store.books[0])
        BookTitleView(book: store.books[1])
        BookTitleView(book: store.books[2])
        BookTitleView(book: store.books[3])
    }
}

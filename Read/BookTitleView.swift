//
//  BookTitleView.swift
//  Read
//
//  Created by Marco S Hyman on 1/31/24.
//

import SwiftData
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
                VStack(alignment: .leading) {
                    ForEach(book.authors) { author in
                        Text(author.name)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading)
                Spacer()
                if let release = book.release {
                    Text("Release date: \(release.formatted(date: .abbreviated, time: .omitted))")
                        .padding(.trailing)
                }
            }
        }
        .padding(5)
    }
}

#Preview {
    let container = Book.preview
    let fetchDescriptor = FetchDescriptor<Book>()
    let book = try! container.mainContext.fetch(fetchDescriptor)[0]
    return List {
        BookTitleView(book: Book(title: "Book Title View Test"))
        BookTitleView(book: Book(title: "Future Release",
                                 release: Calendar.current.date(byAdding: .day,
                                                                value: 1,
                                                                to: Date())!))
        BookTitleView(book: book)
    }
}

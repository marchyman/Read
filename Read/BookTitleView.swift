//
//  BookTitleView.swift
//  Read
//
//  Created by Marco S Hyman on 1/31/24.
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
                ForEach(book.authors ?? []) { author in
                    Text(author.name)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let release = book.release {
                    Text("Release date: \(release.formatted(date: .abbreviated, time: .omitted))")
                        .padding(.trailing)
                }
            }
        }
    }
}

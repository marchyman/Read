//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import SwiftData

@Model
final class Book {
    var added: Date = Date.now
    var title: String = "Unknown"
    @Relationship(deleteRule: .nullify, inverse: \Author.books)
    var authors: [Author]!
    @Relationship(deleteRule: .nullify, inverse: \Series.books)
    var series: Series?
    var seriesOrder: Int?

    init(title: String) {
        self.title = title
        self.authors = []
    }
}

//
//  Book.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import Foundation
import SwiftData

@Model
final class Book {
    var title: String
    var authors: [String]
    var series: String?
    var seriesOrder: Int?
    var added: Date
    var estRelease: Date?

    var authorString: String {
        if authors.count == 1 {
            return authors.first!
        }
        return authors.dropFirst().reduce(authors.first!) { $0 + ", \($1)"}
    }

    init(title: String,
         series: String? = nil,
         seriesOrder: Int? = nil,
         authors: String,
         estRelease: Date? = nil) {
        self.title = title
        self.series = series
        self.seriesOrder = seriesOrder

        let allAuthors = authors.split(separator: ",",
                                       omittingEmptySubsequences: true)
        self.authors = allAuthors.map {String($0) }

        self.added = Date.now
        self.estRelease = estRelease
    }
}

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
    var added: Date = Date.now
    var release: Date?
    var title: String = "Unknown"
    var authors: [Author]?
    @Relationship(deleteRule: .nullify, inverse: \Series.books)
    var series: Series?
    var seriesOrder: Int?

    init(title: String, release: Date? = nil) {
        self.title = title
        self.release = release
        self.authors = []
    }
}

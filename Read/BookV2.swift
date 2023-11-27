//
//  BookV2.swift
//  Read
//
//  Created by Marco S Hyman on 11/26/23.
//

import Foundation
import SwiftData

enum BookSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Book.self]
    }

    @Model
    final class Book {
        var author: String = "Unknown"
        var title: String = "Unknown"
        var series: String?
        var seriesOrder: Int?
        var added: Date = Date.now
        var estRelease: Date?
        var authors: [String] = []
        var lastName: String {
            authors[0]
        }

        init(title: String,
             series: String? = nil,
             seriesOrder: Int? = nil,
             author: String,
             estRelease: Date? = nil) {
            self.author = author
            updateAuthors()
            self.title = title
            self.series = series
            self.seriesOrder = seriesOrder
            self.added = Date.now
            self.estRelease = estRelease
        }

        func updateAuthors() {
            let allAuthors = author.split(separator: ",",
                                          omittingEmptySubsequences: true)
            authors = allAuthors.map { name in
                var components = name.split(separator: " ",
                                            omittingEmptySubsequences: true)
                if components.count > 0 {
                    let lastName = components.removeLast()
                    let otherNames = components.joined(separator: " ")
                    return "\(lastName), \(otherNames)"
                }
                return String(name)
            }
        }
    }
}

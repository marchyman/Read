//
//  Book.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import Foundation
import SwiftData

typealias Book = BookSchemaV2.Book

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

enum BookSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Book.self]
    }

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
}

enum BookMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BookSchemaV1.self, BookSchemaV2.self]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: BookSchemaV1.self,
        toVersion: BookSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            let books = try context.fetch(FetchDescriptor<BookSchemaV2.Book>())
            for book in books {
                if book.authors.isEmpty {
                    book.author = "unknown"
                } else {
                    book.author = book.authors.first!
                    if book.authors.count > 1 {
                        book.author = book.authors.dropFirst().reduce(book.author) {
                            $0 + ", \($1)"
                        }
                    }
                }
            }
            try context.save()
        }
    )

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
}

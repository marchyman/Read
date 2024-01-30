//
//  BookMigration.swift
//  Read
//
//  Created by Marco S Hyman on 11/26/23.
//

import Foundation
import SwiftData

enum BookMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BookSchemaV1.self,
         BookSchemaV2.self,
         BookSchemaV3.self,
         BookSchemaV4.self]
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

    static let migrateV2toV3 = MigrationStage.custom(
        fromVersion: BookSchemaV2.self,
        toVersion: BookSchemaV3.self,
        willMigrate: nil,
        didMigrate: { context in
            let books = try context.fetch(FetchDescriptor<BookSchemaV3.Book>())
            for book in books {
                book.setSortAuthor()
            }
            try context.save()
        }
    )

    static var v3Books: [BookSchemaV3.Book] = []

    static let migrateV3toV4 = MigrationStage.custom(
        fromVersion: BookSchemaV3.self,
        toVersion: BookSchemaV4.self,
        willMigrate: { context in
            // make a copy of the version 3 books
            let books = try context.fetch(FetchDescriptor<BookSchemaV3.Book>())
            for book in books {
                v3Books.append(book)
            }
        },
        didMigrate: { context in
            let books = try context.fetch(FetchDescriptor<BookSchemaV4.Book>())
            let authors = try context.fetch(FetchDescriptor<BookSchemaV4.Author>())
            let series = try context.fetch(FetchDescriptor<BookSchemaV4.Series>())
            for book in books {
                try v4Authors(book, authors: authors, context: context)
                if book.seriesOrder != nil {
                    try v4Series(book, series: series, context: context)
                }
            }
            try context.save()
            // no longer need the copies
            v3Books = []
        }
    )

    static func v4Authors(_ book: BookSchemaV4.Book,
                          authors: [BookSchemaV4.Author],
                          context: ModelContext) throws {
        // make sure the array of authors for the book is not nil
        if book.authors == nil {
            book.authors = []
        }

        if let v3Book = v3Books.first(where: {$0.title == book.title}) {
            // extract authors from the V3 version of the book
            let allAuthors = v3Book.author.split(separator: ",",
                                                 omittingEmptySubsequences: true)
            for name in allAuthors {
                var components = name.split(separator: " ",
                                            omittingEmptySubsequences: true)
                let lastName: String
                let firstName: String
                switch components.count {
                case 1:
                    lastName = "\(components[0])"
                    firstName = ""
                case 1...:
                    lastName = "\(components.removeLast())"
                    firstName = "\(components.joined(separator: " "))"
                default:
                    lastName = "Unknown"
                    firstName = ""
                }

                // see if there is an existing author.  If not create
                // an entry for the author and insert it into the context.
                let existingAuthor = authors.first(where: {
                    $0.lastName == lastName && $0.firstName == firstName
                })
                let author: BookSchemaV4.Author
                if let existingAuthor {
                    author = existingAuthor
                } else {
                    author = BookSchemaV4.Author(lastName: lastName,
                                                 firstName: firstName)
                    context.insert(author)
                    author.books = []
                }

                // add the author to the book and the book to the author
                // the arrayis are guaranteed non-nil at this point
                book.authors!.append(author)
                author.books!.append(book)
                try context.save()
            }
        }
    }

    static func v4Series(_ book: BookSchemaV4.Book,
                         series: [BookSchemaV4.Series],
                         context: ModelContext) throws {
        if let v3Book = v3Books.first(where: {$0.title == book.title}) {
            guard let v3Series = v3Book.series else { return }
            let existingSeries = series.first(where: {
                $0.name == v3Series
            })
            let series: BookSchemaV4.Series
            if let existingSeries {
                series = existingSeries
            } else {
                series = BookSchemaV4.Series(name: v3Series)
                context.insert(series)
                series.books = []
            }

            // add the series to the book and the book to the series
            book.series = series
            series.books!.append(book)
            try context.save()
        }
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2,
         migrateV2toV3,
         migrateV3toV4]
    }
}

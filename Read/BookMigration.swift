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
        [BookSchemaV1.self, BookSchemaV2.self, BookSchemaV3.self]
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

    static var stages: [MigrationStage] {
        [migrateV1toV2,
         migrateV2toV3]
    }
}

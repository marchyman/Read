//
//  BookV4.swift
//  Read
//
//  Created by Marco S Hyman on 1/26/24.
//

import Foundation
import SwiftData

enum BookSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(4, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Book.self]
    }

    @Model
    final class Book {
        var added: Date = Date.now
        var release: Date?
        var title: String = "Unknown"
        var authors: [Author]?
        var series: Series?
        var seriesOrder: Int?

        init(title: String, release: Date? = nil) {
            self.title = title
            self.release = release
        }
    }

    @Model
    final class Author {
        var lastName: String = ""
        var firstName: String = ""
        var books: [Book]?
        
        init(lastName: String, firstName: String = "") {
            self.lastName = lastName
            self.firstName = firstName
        }
    }

    @Model
    final class Series {
        var name: String = ""
        var books: [Book]?

        init(name: String) {
            self.name = name
        }
    }

}

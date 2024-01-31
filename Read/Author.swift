//
//  Author.swift
//  Read
//
//  Created by Marco S Hyman on 1/31/24.
//

import Foundation
import SwiftData

@Model
final class Author {
    var id: UUID = UUID()
    var lastName: String = ""
    var firstName: String = ""
    var books: [Book]?

    init(lastName: String, firstName: String = "") {
        self.lastName = lastName
        self.firstName = firstName
        self.books = []
    }
}

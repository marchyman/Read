//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import SwiftData

@Model
final class Author {
    var id: UUID = UUID()
    var lastName: String = ""
    var firstName: String = ""
    var books: [Book]!
    var expanded: Bool = false

    var name: String {
        return "\(firstName) \(lastName)"
    }

    init(lastName: String, firstName: String = "") {
        self.lastName = lastName
        self.firstName = firstName
        self.books = []
        self.expanded = false
    }
}

//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import SwiftData

@Model
final class Series {
    var name: String = ""
    var books: [Book]!
    var expanded: Bool = false

    init(name: String) {
        self.name = name
        self.books = []
        self.expanded = false
    }
}

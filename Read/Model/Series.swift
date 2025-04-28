//
//  Series.swift
//  Read
//
//  Created by Marco S Hyman on 1/31/24.
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

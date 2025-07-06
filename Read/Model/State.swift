//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import OSLog
import SwiftData

struct BookState: Equatable {
    var books: [Book] = []
    var authors: [Author] = []
    var series: [Series] = []
    var bookDB: BookDB
    var lastError: String?

    init(forPreview: Bool = false, addTestData: Bool = false) {
        var inMemory = forPreview
        if CommandLine.arguments.contains("-TESTING") {
            inMemory = true
        }
        bookDB = try! BookDB(inMemory: inMemory, addTestData: addTestData)
        self.books = (try? sortedBooks()) ?? []
        self.authors = (try? sortedAuthors()) ?? []
        self.series = (try? sortedSeries()) ?? []
    }
}

extension BookState {
    func sortedBooks() throws -> [Book] {
        return try bookDB.read(sortBy: [SortDescriptor<Book>(\.title)])
    }

    func sortedAuthors() throws -> [Author] {
        return try bookDB.read(sortBy: [
            SortDescriptor<Author>(\.lastName),
            SortDescriptor<Author>(\.firstName)
        ])
    }

    func sortedSeries() throws -> [Series] {
        return try bookDB.read(sortBy: [SortDescriptor<Series>(\.name)])
    }
}

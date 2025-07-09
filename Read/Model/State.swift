//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import OSLog

struct BookState: Equatable {
    var books: [Book] = []
    var authors: [Author] = []
    var series: [Series] = []
    var bookDB: BookDB
    var lastError: String?

    // command line args, use for testing, override function args.
    init(forPreview: Bool = false, addTestData: Bool = false) {
        var inMemoryFlag = forPreview
        if CommandLine.arguments.contains("-MEMORY") {
            inMemoryFlag = true
        }
        var testDataFlag = addTestData
        if CommandLine.arguments.contains("-TESTDATA") {
            testDataFlag = true
        }
        bookDB = try! BookDB(inMemory: inMemoryFlag, addTestData: testDataFlag)
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

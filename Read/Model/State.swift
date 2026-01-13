//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//
// This file defines the BookState structure which serves as the
// central state manager for the Read application. It coordinates
// data access through the BookDB and maintains sorted collections
// of books, authors, and series for UI presentation.
//
// The state is designed to work with the UDF (Unified Data Flow)
// pattern where UI modifications are handled through reducer
// functions that update state and trigger database operations.
//

import OSLog

struct BookState: Equatable {
    var books: [Book] = []
    var authors: [Author] = []
    var series: [Series] = []
    var bookDB: BookDB
    var lastError: String?

    init(forPreview: Bool = false, addTestData: Bool = false) {
        // command line args, used when testing, override function args.
        let inMemoryFlag = if CommandLine.arguments.contains("-MEMORY") {
            true
        } else {
            forPreview
        }
        let testDataFlag = if CommandLine.arguments.contains("-TESTDATA") {
            true
        } else {
            addTestData
        }
        bookDB = try! BookDB(inMemory: inMemoryFlag, addTestData: testDataFlag)
        self.books = (try? sortedBooks()) ?? []
        self.authors = (try? sortedAuthors()) ?? []
        self.series = (try? sortedSeries()) ?? []
        Logger(subsystem: "org.snafu", category: "BookState")
            .info("Book state created")
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

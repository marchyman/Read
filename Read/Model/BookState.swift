//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import OSLog
import SwiftData

struct BookState {
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
        switch sortedBooks() {
        case .success(let books):
            self.books = books
        case .failure(let error):
            lastError = error.localizedDescription
        }
        switch sortedAuthors() {
        case .success(let authors):
            self.authors = authors
        case .failure(let error):
            lastError = error.localizedDescription
        }
        switch sortedSeries() {
        case .success(let series):
            self.series = series
        case .failure(let error):
            lastError = error.localizedDescription
        }
    }
}

extension BookState {
    func sortedBooks() -> Result<[Book], Error> {
        do {
            let books = try bookDB.read(sortBy: [SortDescriptor<Book>(\.title)])
            return .success(books)
        } catch {
            return .failure(error)
        }
    }

    func sortedAuthors() -> Result<[Author], Error> {
        do {
            let authors = try bookDB.read(sortBy: [
                SortDescriptor<Author>(\.lastName),
                SortDescriptor<Author>(\.firstName)
            ])
            return .success(authors)
        } catch {
            return .failure(error)
        }
    }

    func sortedSeries() -> Result<[Series], Error> {
        do {
            let series = try bookDB.read(sortBy: [SortDescriptor<Series>(\.name)])
            return .success(series)
        } catch {
            return .failure(error)
        }
    }
}

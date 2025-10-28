//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import OSLog
import UDF

enum ModelEvent: Equatable {
    case addAuthorButton(Author)
    case addBookButton(Book)
    case bookUpdateOrAddButton(Book, String, [Author], String, Int)
    case editAuthorDone(Author, String, String)
    case editSeriesDone(Series, String)
    case onAuthorDelete(Author)
    case onBookDelete(Book)
    case onSeriesDelete(Series)
}

struct ModelReducer: Reducer {
    let logger = Logger(subsystem: "org.snafu", category: "reducer")

    func reduce(_ state: BookState,
                _ event: ModelEvent) -> BookState {
        var newState = state

        switch event {
        case .addAuthorButton(let author):
            addAuthorButton(state: &newState, author: author)
        case .addBookButton(let book):
            addBookButton(state: &newState, book: book)
        case .bookUpdateOrAddButton(let book, let title, let authors,
                                    let seriesName, let seriesOrder):
            bookUpdateOrAddButtin(&newState, book, title, authors,
                                  seriesName, seriesOrder)
        case .editAuthorDone(let author, let firstName, let lastName):
            editAuthorDone(state: &newState, author: author,
                           firstName: firstName, lastName: lastName)
        case .editSeriesDone(let series, let name):
            editSeriesDone(state: &newState, series: series, name: name)
        case .onAuthorDelete(let author):
            onAuthorDelete(state: &newState, author: author)
        case .onBookDelete(let book):
            onBookDelete(state: &newState, book: book)
        case .onSeriesDelete(let series):
            onSeriesDelete(state: &newState, series: series)
        }

        return newState
    }
}

// reducer helper functions
extension ModelReducer {

    private func addAuthorButton(state: inout BookState, author: Author) {
        do {
            try state.bookDB.create(item: author)
            try state.authors = state.sortedAuthors()
            logger.info("Added author \(author.name, privacy: .public)")
        } catch {
            let errorTxt = error.localizedDescription
            state.lastError = errorTxt
            logger.error("""
                Failed to add author \(author.name, privacy: .public)
                error: \(errorTxt, privacy: .public)
                """)
        }
    }

    private func addBookButton(state: inout BookState, book: Book) {
        do {
            try state.bookDB.create(item: book)
            try state.books = state.sortedBooks()
            logger.info("Added book \(book.title, privacy: .public)")
        } catch {
            let errorTxt = error.localizedDescription
            state.lastError = errorTxt
            logger.error("""
                Failed to add book \(book.title, privacy: .public)
                error: \(errorTxt, privacy: .public)
                """)
        }
    }

    // swiftlint:disable:next function_parameter_count
    private func bookUpdateOrAddButtin(_ state: inout BookState,
                                       _ book: Book, _ title: String,
                                       _ authors: [Author],
                                       _ seriesName: String,
                                       _ seriesOrder: Int) {
        func getSeries(matching name: String) -> Series {
            if let series = state.series.first(where: {
                $0.name == name
            }) {
                return series
            }
            return Series(name: name)
        }

        do {
            // title change
            if book.title != title {
                book.title = title
                try state.bookDB.update(book: book, title: title)
                state.books = try state.sortedBooks()
                logger.info("Updated book (title) \(title, privacy: .public)")
            }
            // author change
            if book.authors != authors {
                try state.bookDB.update(book: book, authors: authors)
                state.authors = try state.sortedAuthors()
                logger.info("Updated book (authors) \(title, privacy: .public)")
            }
            // series change and/or series order change
            if seriesName.isEmpty {
                if book.series != nil {
                    // delete the series and the seriesOrder from the book
                    try state.bookDB.update(book: book, series: nil, order: nil)
                    logger.info("Updated book (removed series) \(title, privacy: .public)")
                }
            } else {
                let series = getSeries(matching: seriesName)
                if book.series != series {
                    try state.bookDB.update(book: book, series: series,
                                            order: seriesOrder)
                    state.series = try state.sortedSeries()
                    logger.info("Updated book (series) \(title, privacy: .public)")
                } else if book.seriesOrder != seriesOrder {
                    try state.bookDB.update(book: book, order: seriesOrder)
                    logger.info("Updated book (seriesOrder) \(title, privacy: .public)")
                }
            }
        } catch {
            let errorTxt = error.localizedDescription
            state.lastError = errorTxt
            logger.error("""
                Failed to update \(book.title, privacy: .public)
                error: \(errorTxt, privacy: .public)
                """)
        }
    }

    private func editAuthorDone(state: inout BookState, author: Author,
                                firstName: String, lastName: String) {
        do {
            try state.bookDB.update(author: author, firstName: firstName,
                                    lastName: lastName)
            state.authors = try state.sortedAuthors()
            logger.info("Updated author \(author.name, privacy: .public)")
        } catch {
            let errorTxt = error.localizedDescription
            state.lastError = errorTxt
            logger.error("""
                Failed to update author \(author.name, privacy: .public)
                error: \(errorTxt, privacy: .public)
                """)
        }
    }

    private func editSeriesDone(state: inout BookState,
                                series: Series, name: String) {
        do {
            try state.bookDB.update(series: series, name: name)
            state.series = try state.sortedSeries()
            logger.info("Updated series \(series.name, privacy: .public)")
        } catch {
            let errorTxt = error.localizedDescription
            state.lastError = errorTxt
            logger.error("""
                Failed to update series \(series.name, privacy: .public)
                error: \(errorTxt, privacy: .public)
                """)
        }
    }

    private func onAuthorDelete(state: inout BookState, author: Author) {
        let name = author.name
        do {
            author.books = []
            try state.bookDB.delete(element: author)
            state.authors = try state.sortedAuthors()
            logger.info("Deleted author \(name, privacy: .public)")
        } catch {
            let errorTxt = error.localizedDescription
            state.lastError = errorTxt
            logger.error("""
                Failed to delete author \(name, privacy: .public)
                error: \(errorTxt, privacy: .public)
                """)
        }
    }

    private func onBookDelete(state: inout BookState, book: Book) {
        let title = book.title
        do {
            try state.bookDB.delete(element: book)
            state.books = try state.sortedBooks()
            logger.info("Deleted book \(title, privacy: .public)")
        } catch {
            let errorTxt = error.localizedDescription
            state.lastError = errorTxt
            logger.error("""
                Failed to delete book \(title, privacy: .public)
                error: \(errorTxt, privacy: .public)
                """)
        }
    }

    private func onSeriesDelete(state: inout BookState, series: Series) {
        let name = series.name
        do {
            for book in series.books {
                book.series = nil
                book.seriesOrder = nil
            }
            try state.bookDB.delete(element: series)
            state.series = try state.sortedSeries()
            logger.info("Deleted series \(name, privacy: .public)")
        } catch {
            let errorTxt = error.localizedDescription
            state.lastError = errorTxt
            logger.error("""
                Failed to delete series \(name, privacy: .public)
                error: \(errorTxt, privacy: .public)
                """)
        }
    }

}

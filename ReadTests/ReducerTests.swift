//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import SwiftData
import Testing
import UDF

@testable import Read

@MainActor
struct ReducerTests {
    func store(withTestData: Bool) -> Store<BookState, ModelEvent> {
        Store(initialState: BookState(addTestData: withTestData),
              reduce: ModelReducer())
    }

    @Test func addAuthor() async throws {
        let store = store(withTestData: false)
        #expect(store.authors.count == 0)
        let author = Author(lastName: "Doe", firstName: "John")
        await store.send(.addAuthorButton(author))
        #expect(store.authors.count == 1)
        #expect(store.authors[0].name == "John Doe")
    }

    @Test func addBook() async throws {
        let title = "Test Book"
        let store = store(withTestData: false)
        #expect(store.books.count == 0)
        let book = Book(title: title)
        await store.send(.addBookButton(book))
        #expect(store.books.count == 1)
        #expect(store.books[0].title == title)
    }

    @Test func updateBookTitle() async throws {
        let title = "Test Book"
        let store = store(withTestData: false)
        let book = Book(title: title)
        await store.send(.addBookButton(book))
        let newTitle = "Updated Test Book"
        let authors = book.authors!
        let seriesName = ""
        let seriesOrder = 0
        await store.send(.bookUpdateOrAddButton(book, newTitle, authors,
                                                seriesName, seriesOrder))
        #expect(book.title == newTitle)
        #expect(book.authors == authors)
        #expect(book.series == nil)
        #expect(book.seriesOrder == nil)
    }

    @Test func updateBookAuthors() async throws {
        let title = "Test Book"
        let store = store(withTestData: false)
        let book = Book(title: title)
        await store.send(.addBookButton(book))
        let authors = [Author(lastName: "Doe", firstName: "John")]
        let seriesName = ""
        let seriesOrder = 0
        await store.send(.bookUpdateOrAddButton(book, title, authors,
                                                seriesName, seriesOrder))
        #expect(book.title == title)
        #expect(book.authors == authors)
        #expect(book.series == nil)
        #expect(book.seriesOrder == nil)
    }

    @Test func updateBookSeries() async throws {
        let title = "Test Book"
        let book = Book(title: title)
        let authors = book.authors!
        let seriesName = "Test Series"
        let seriesOrder = 3
        let store = store(withTestData: false)
        await store.send(.addBookButton(book))

        await store.send(.bookUpdateOrAddButton(book, title, authors,
                                                seriesName, seriesOrder))
        #expect(book.series != nil)
        #expect(book.series?.name == seriesName)
        #expect(book.seriesOrder != nil)
        #expect(book.seriesOrder == seriesOrder)

        // change the series order
        await store.send(.bookUpdateOrAddButton(book, title, authors,
                                                seriesName, seriesOrder - 1))
        #expect(book.series != nil)
        #expect(book.series?.name == seriesName)
        #expect(book.seriesOrder != nil)
        #expect(book.seriesOrder == seriesOrder - 1)

        // delete the series
        await store.send(.bookUpdateOrAddButton(book, title, authors, "", 0))
        #expect(book.series == nil)
        #expect(book.seriesOrder == nil)
    }

    @Test func editAuthorDone() async throws {
        let store = store(withTestData: false)
        let author = Author(lastName: "Doe", firstName: "John")
        await store.send(.addAuthorButton(author))
        let newFirstName = "Mary"
        let newLastName = "Roe"
        await store.send(.editAuthorDone(author, newFirstName, newLastName))
        #expect(author.firstName == newFirstName)
        #expect(author.lastName == newLastName)
    }

    @Test func editSeriesDone() async throws {
        // the only way to create a series is to add a name/order to a book
        let title = "Test Book"
        let book = Book(title: title)
        let authors = book.authors!
        let seriesName = "Test Series"
        let seriesOrder = 3
        let store = store(withTestData: false)
        await store.send(.addBookButton(book))

        await store.send(.bookUpdateOrAddButton(book, title, authors,
                                                seriesName, seriesOrder))
        #expect(store.series.count == 1)
        let series = store.series[0]
        let updatedSeriesName = "Test Series (updated)"
        await store.send(.editSeriesDone(series, updatedSeriesName))
        #expect(series.name == updatedSeriesName)
    }

    @Test func onAuthorDelete() async throws {
        let store = store(withTestData: false)
        let author = Author(lastName: "Doe", firstName: "John")
        await store.send(.addAuthorButton(author))
        #expect(store.authors.count == 1)

        await store.send(.onAuthorDelete(author))
        #expect(store.authors.count == 0)
    }

    @Test func onBookDelete() async throws {
        let store = store(withTestData: false)
        let book = Book(title: "Title")
        await store.send(.addBookButton(book))
        #expect(store.books.count == 1)

        await store.send(.onBookDelete(book))
        #expect(store.books.count == 0)
    }

    @Test func onSeriesDelete() async throws {
        // the only way to create a series is to add a name/order to a book
        let title = "Test Book"
        let book = Book(title: title)
        let authors = book.authors!
        let seriesName = "Test Series"
        let seriesOrder = 3
        let store = store(withTestData: false)
        await store.send(.addBookButton(book))

        await store.send(.bookUpdateOrAddButton(book, title, authors,
                                                seriesName, seriesOrder))
        #expect(store.series.count == 1)
        let series = store.series[0]

        await store.send(.onSeriesDelete(series))
        #expect(store.series.count == 0)
    }
}

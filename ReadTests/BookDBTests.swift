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
struct BookDBTests {
    @Test func newDB() async throws {
        let testDB = try BookDB(inMemory: true)
        let books = try testDB.context.fetch(FetchDescriptor<Book>())
        #expect(books.isEmpty)
    }

    @Test func addBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)
        let books = try testDB.context.fetch(FetchDescriptor<Book>())
        #expect(!books.isEmpty)
    }

    @Test func addAuthorToBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)
        let author = Author(lastName: "Last", firstName: "First")
        try testDB.update(book: book, author: author)
        let authors = try testDB.context.fetch(FetchDescriptor<Author>())
        #expect(authors.count == 1)
        #expect(author.books.count == 1)
        #expect(author.books.first == book)
        #expect(book.authors.first == author)
    }

    @Test func addSeriesToBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)
        let series = Series(name: "A Series")
        try testDB.update(book: book, series: series, order: 1)
        let allSeries = try testDB.context.fetch(FetchDescriptor<Series>())
        #expect(allSeries.count == 1)
        #expect(book.series == series)
        #expect(book.seriesOrder == 1)
        #expect(series.books.first == book)
    }

    @Test func deleteBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)

        try testDB.delete(element: book)
        let books = try testDB.context.fetch(FetchDescriptor<Book>())
        #expect(books.isEmpty)
    }

    @Test func deleteAuthor() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)
        let author = Author(lastName: "Last", firstName: "First")
        try testDB.update(book: book, author: author)

        try testDB.delete(element: author)
        let authors = try testDB.context.fetch(FetchDescriptor<Author>())
        #expect(authors.isEmpty)
        let books = try testDB.context.fetch(FetchDescriptor<Book>())
        let firstBook = try #require(books.first)
        #expect(firstBook.authors.isEmpty)
    }

    @Test func deleteSeries() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)
        let series = Series(name: "Test Series")
        try testDB.update(book: book, series: series, order: 1)

        try testDB.delete(element: series)
        let allSeries = try testDB.context.fetch(FetchDescriptor<Series>())
        #expect(allSeries.isEmpty)
        let books = try testDB.context.fetch(FetchDescriptor<Book>())
        let firstBook = try #require(books.first)
        #expect(firstBook.series == nil)
    }

    @Test func readTests() async throws {
        let testDB = try BookDB(inMemory: true, addTestData: true)
        let books = try testDB.read(sortBy: [SortDescriptor<Book>(\.title)])
        let authors = try testDB.read(sortBy: [
            SortDescriptor<Author>(\.lastName),
            SortDescriptor<Author>(\.firstName)
        ])
        let series = try testDB.read(sortBy: [SortDescriptor<Series>(\.name)])
        let firstBook = try #require(books.first)
        #expect(firstBook.title == "A Standalone Book")
        let firstAuthor = try #require(authors.first)
        #expect(firstAuthor.name == "John Doe")
        let firstSeries = try #require(series.first)
        #expect(firstSeries.name == "Test Series")
    }
}

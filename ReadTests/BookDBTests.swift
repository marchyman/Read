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

    @Test func addAuthorsToBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)
        let author = Author(lastName: "Last", firstName: "First")
        try testDB.update(book: book, authors: [author])
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

    @Test func changeAuthors() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)
        let author1 = Author(lastName: "One", firstName: "First")
        let author2 = Author(lastName: "Two", firstName: "Second")
        let author3 = Author(lastName: "Three", firstName: "Third")
        try testDB.update(book: book, authors: [author1, author2])
        let authors = try testDB.context.fetch(FetchDescriptor<Author>())
        #expect(authors.count == 2)
        // let firstAuthorForBook = book.authors.first
        try testDB.update(book: book, authors: [author2, author3])
        let updatedAuthors = try testDB.context.fetch(FetchDescriptor<Author>())
        for author in updatedAuthors {
            let count = author.books?.count ?? 0
            print("\(author.lastName) has \(count) books")
        }
        // This is wrong... authors with no books are not automatically
        // removed.  I'll need to do that manually
        // #expect(updatedAuthors.count == 2)

        // #expect(book.authors.first != firstAuthorForBook)
    }

    @Test func deleteAuthor() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(book: book)
        let author = Author(lastName: "Last", firstName: "First")
        try testDB.update(book: book, authors: [author])

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

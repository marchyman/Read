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
        let authors = try testDB.context.fetch(FetchDescriptor<Author>())
        #expect(authors.isEmpty)
        let series = try testDB.context.fetch(FetchDescriptor<Series>())
        #expect(series.isEmpty)
    }

    @Test func addBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(item: book)
        let books = try testDB.context.fetch(FetchDescriptor<Book>())
        #expect(books.count == 1)
    }

    @Test func addAuthorToBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let author = Author(lastName: "Last", firstName: "First")
        try testDB.create(item: author)
        let authors = try testDB.context.fetch(FetchDescriptor<Author>())
        #expect(authors.count == 1)
    }

    @Test func addSeriesToBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let series = Series(name: "Series Name")
        try testDB.create(item: series)
        let allSeries = try testDB.context.fetch(FetchDescriptor<Series>())
        #expect(allSeries.count == 1)
    }

    @Test func readData() async throws {
        let testDB = try BookDB(inMemory: true, addTestData: true)
        let books = try testDB.read(sortBy: [SortDescriptor<Book>(\.title)])
        let authors = try testDB.read(sortBy: [
            SortDescriptor<Author>(\.lastName),
            SortDescriptor<Author>(\.firstName)
        ])
        let series = try testDB.read(sortBy: [SortDescriptor<Series>(\.name)])
        #expect(books.count == 4)
        #expect(authors.count == 4)
        #expect(series.count == 1)
    }

    @Test func updateBookTitle() async throws {
        let testTitle = "A Changed Title"
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(item: book)
        try testDB.update(book: book, title: testTitle)
        #expect(book.title == testTitle)
    }

    @Test func updateBookAuthors() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(item: book)
        let author = Author(lastName: "Last", firstName: "First")
        try testDB.update(book: book, authors: [author])
        let authors = try testDB.context.fetch(FetchDescriptor<Author>())
        #expect(authors.count == 1)
        #expect(author.books.count == 1)
        #expect(author.books.first == book)
        #expect(book.authors.first == author)
    }

    @Test func updateBookSeries() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(item: book)
        let series = Series(name: "A Series")
        try testDB.update(book: book, series: series, order: 1)
        let allSeries = try testDB.context.fetch(FetchDescriptor<Series>())
        #expect(allSeries.count == 1)
        #expect(book.series == series)
        #expect(book.seriesOrder == 1)
        #expect(series.books.first == book)
        // now remove the series
        try testDB.update(book: book, series: nil, order: nil)
        #expect(book.series == nil)
        #expect(book.seriesOrder == nil)
    }

    @Test func updateBookSeriesOrder() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(item: book)
        let series = Series(name: "A Series")
        try testDB.update(book: book, series: series, order: 1)
        #expect(book.seriesOrder == 1)
        try testDB.update(book: book, order: 2)
        #expect(book.seriesOrder == 2)
    }

    @Test func updateAuthorName() async throws {
        let testDB = try BookDB(inMemory: true)
        let author = Author(lastName: "Last", firstName: "First")
        try testDB.create(item: author)
        try testDB.update(author: author, firstName: "John", lastName: "Doe")
        #expect(author.name == "John Doe")
    }

    @Test func updateSeriesName() async throws {
        let newName = "Changed Name of Series"
        let testDB = try BookDB(inMemory: true)
        let series = Series(name: "Series One")
        try testDB.create(item: series)
        try testDB.update(series: series, name: newName)
        #expect(series.name == newName)
    }

    @Test func deleteBook() async throws {
        let testDB = try BookDB(inMemory: true)
        let book = Book(title: "A Test Book")
        try testDB.create(item: book)

        try testDB.delete(element: book)
        let books = try testDB.context.fetch(FetchDescriptor<Book>())
        #expect(books.isEmpty)
    }

    @Test func deleteAuthor() async throws {
        let testDB = try BookDB(inMemory: true)
        let author = Author(lastName: "Doe", firstName: "John")
        try testDB.create(item: author)

        try testDB.delete(element: author)
        let authors = try testDB.context.fetch(FetchDescriptor<Author>())
        #expect(authors.isEmpty)
    }

    @Test func deleteSeries() async throws {
        let testDB = try BookDB(inMemory: true)
        let series = Series(name: "One to delete")
        try testDB.create(item: series)

        try testDB.delete(element: series)
        let seriesList = try testDB.context.fetch(FetchDescriptor<Series>())
        #expect(seriesList.isEmpty)
    }

}

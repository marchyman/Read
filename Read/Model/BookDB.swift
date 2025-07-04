//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import SwiftData

final class BookDB {
    let container: ModelContainer
    let context: ModelContext

    init(inMemory: Bool = false, addTestData: Bool = false) throws {
        let configuration = ModelConfiguration(for: Book.self,
                                               isStoredInMemoryOnly: inMemory)
        container = try ModelContainer(for: Book.self,
                                       configurations: configuration)
        context = ModelContext(container)
        if addTestData {
            let books = addTestBooks()
            addTestAuthors(books)
            addTestSeries(books)
            try context.save()
        }
    }
}

// create test data for previews and unit tests

extension BookDB {
    func addTestBooks() -> [Book] {
        // Define some books and add them to the container's context
        let books: [Book] = [
            Book(title: "A Standalone Book"),
            Book(
                title: "Future Release",
                release: Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: Date())!),
            Book(title: "First book of a series"),
            Book(title: "Second book of a series")
        ]
        for book in books {
            context.insert(book)
        }
        return books
    }

    func addTestAuthors(_ books: [Book]) {
        // create some authors
        let author1 = Author(lastName: "Jones", firstName: "Davey")
        let author2 = Author(lastName: "Doe", firstName: "John")
        let author3 = Author(lastName: "Roe", firstName: "Mary")
        let author4 = Author(lastName: "McDonald", firstName: "Ronald")

        // Assign authors to book
        books[0].authors.append(author1)
        books[1].authors.append(author2)
        books[1].authors.append(author3)
        books[2].authors.append(author4)
        books[3].authors.append(author4)
    }

    func addTestSeries(_ books: [Book]) {
        let series = Series(name: "Test Series")
        books[2].series = series
        books[2].seriesOrder = 1
        books[3].series = series
        books[3].seriesOrder = 2
    }
}

// BookDB CRUD functions
//
// Design note: All database updates happen in the following functions.
// At no time will the UI code modify a database item. Instead, the UI
// code updates copies of the fields.  Updated fields are processed by
// a reducer which then calls one of these functions to perform the
// actual update.
//
// The read function is used to access arrays of current items in
// a given order.
//
// And because every rule need and exception there is a case where the
// UI code directly updates a database item: toggling a boolean the determines
// if the contents of a disclosure group is presented.

extension BookDB {
    func create<T: PersistentModel>(item: T) throws {
        context.insert(item)
        try context.save()
    }

    func read<T: PersistentModel>(sortBy sortDescriptors: [SortDescriptor<T>]) throws -> [T] {
        let fetchDescriptor = FetchDescriptor<T>(sortBy: sortDescriptors)
        return try context.fetch(fetchDescriptor)
    }

    func update(book: Book, title: String) throws {
        book.title = title
        try context.save()
    }

    func update(book: Book, authors: [Author]) throws {
        book.authors = authors
        try context.save()
    }

    func update(book: Book, series: Series?, order: Int?) throws {
        book.series = series
        book.seriesOrder = order
        try context.save()
    }

    func update(book: Book, order: Int?) throws {
        book.seriesOrder = order
        try context.save()
    }

    func update(author: Author, firstName: String, lastName: String) throws {
        author.firstName = firstName
        author.lastName = lastName
        try context.save()
    }

    func update(series: Series, name: String) throws {
        series.name = name
        try context.save()
    }

    func delete<T: PersistentModel>(element: T) throws {
        let idToDelete = element.persistentModelID
            try context.delete(model: T.self,
                               where: #Predicate { element in
                                   element.persistentModelID == idToDelete
                               })
    }
}

//
//  BookPreview.swift
//  Read
//
//  Created by Marco S Hyman on 3/14/24.
//

import Foundation
import SwiftData

extension Book {
    @MainActor
    static var preview: ModelContainer {
        // swiftlint:disable force_try
        let container = try! ModelContainer(
            for: Book.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        // swiftlint:enable force_try

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
            container.mainContext.insert(book)
        }

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

        // create a series
        let series = Series(name: "Test Series")
        books[2].series = series
        books[2].seriesOrder = 1
        books[3].series = series
        books[3].seriesOrder = 2

        return container
    }
}

//
//  PreviewData.swift
//  Read
//
//  Created by Marco S Hyman on 2/7/24.
//

import Foundation
import SwiftData

@MainActor
struct PreviewData {
    static let container: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Book.self,
                                               configurations: config)
            addSeries(container)
            addAuthors(container)
            addBooks(container)
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()

    static
    func addSeries(_ container: ModelContainer) {
        let names = [
            "Test Series 1",
            "Another Test Series"
        ]
        for name in names {
            let series = Series(name: name)
            container.mainContext.insert(series)
        }
    }

    static
    func addAuthors(_ container: ModelContainer) {
        let names = [
            ("John", "Doe"),
            ("Jane", "Roe"),
            ("", "Anonymous")
        ]
        for name in names {
            let author = Author(lastName: name.1, firstName: name.0)
            container.mainContext.insert(author)
        }
    }

    static
    func addBooks(_ container: ModelContainer) {
        let titles = [
            "The Name of the Book",
            "Who Wrote This",
            "Test Series"
        ]

        for title in titles {
            let book = Book(title: title)
            container.mainContext.insert(book)
        }
    }
}

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
struct StateTests {
    // Should get same results when testing regardless of the state of
    // the forPreview argument.

    @Test(arguments: [true, false])
    func stateInit(arg: Bool) async throws {
        let state = BookState(forPreview: arg, addTestData: true)
        #expect(state.books.count == 4)
        #expect(state.authors.count == 4)
        #expect(state.series.count == 1)
    }

    @Test func relationshipCheck() async throws {
        let state = BookState(addTestData: true)
        let series = try #require(state.series.first)
        let book = try #require(state.books.first(where: {
            $0.series == series
        }))
        _ = try #require(state.authors.first(where: {
            $0.books.contains(book)
        }))
    }
}

//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct ContentView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store
    @State private var errorAlert = false

    var body: some View {
        SelectView()
            .onChange(of: store.lastError) {
                if store.lastError != nil {
                    errorAlert.toggle()
                }
            }
            .alert("Something unexpected happened", isPresented: $errorAlert) {
                // system provides a button to dismiss
            } message: {
                Text("""
                    Error text:

                    \(store.lastError ?? "unknown error")
                    """)
            }
    }
}

struct StatsView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store

    var body: some View {
        Text("""
            ^[\(store.books.count) Book](inflect: true), \
            ^[\(store.authors.count) Author](inflect: true), \
            ^[\(store.series.count) Series](inflect: true)
            """)
    }
}

#Preview {
    ContentView()
        .environment(Store(initialState: BookState(forPreview: true,
                                                   addTestData: true),
                           reduce: ModelReducer()))
}

//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct ContentView: View {
    @Environment(Store<BookState, ModelAction>.self) var store
    @State private var showLog = false

    var body: some View {
        TabsView()
        statsView
            .padding(.bottom, 8)
            .onTapGesture {
                showLog.toggle()
            }
            .sheet(isPresented: $showLog) { LogView() }
    }

    var statsView: some View {
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

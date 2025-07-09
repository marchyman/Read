//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

@main
struct ReadApp: App {
    @State private var store = Store(initialState: BookState(),
                                     reduce: ModelReducer(),
                                     name: "Books DB Store")
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(store)
    }
}

//
//  ReadApp.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftData
import SwiftUI

@main
struct ReadApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Book.self])
        let modelConfiguration = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

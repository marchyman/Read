//
//  AuthorsView.swift
//  Read
//
//  Created by Marco S Hyman on 1/30/24.
//

import SwiftData
import SwiftUI

struct AuthorsView: View {
    @Environment(\.modelContext) private var context
    @Query private var authors: [Author]
    @Binding var selectedAuthors: Set<UUID>
    @State private var selection: Author? = nil
    @State private var newAuthor = false

    var body: some View {
        VStack( alignment: .leading) {
            if !authors.isEmpty {
                List(authors, selection: $selectedAuthors ) { author in
                    Text(author.name)
                }
            }
            Button("Add Author", systemImage: "plus",
                   action: { newAuthor = true })
                .buttonStyle(.bordered)
                .padding()
        }
        .sheet(isPresented: $newAuthor) {
            NewAuthorView()
        }
    }
}

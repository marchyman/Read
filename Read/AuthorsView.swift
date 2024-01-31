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

    var body: some View {
        VStack( alignment: .leading) {
            if !authors.isEmpty {
                List(authors, selection: $selectedAuthors ) { author in
                    Text("\(author.firstName) \(author.lastName)")
                }
            }

            Button(action: addAuthor) {
                Label("Add Author", systemImage: "character.book.closed")
            }
        }
    }

    func addAuthor() {
        //
    }
}

#Preview {
    @State var authors: Set<UUID> = []
    return AuthorsView(selectedAuthors: $authors)
        .modelContainer(for: Book.self, inMemory: true)
}

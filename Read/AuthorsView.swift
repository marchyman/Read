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

    var body: some View {
        List {
            ForEach(authors) { author in
                Text("\(author.firstName) \(author.lastName)")
            }
        }
        Button(action: addAuthor) {
            Label("Add Author", systemImage: "character.book.closed")
        }
    }

    func addAuthor() {
        //
    }
}

#Preview {
    AuthorsView()
        .modelContainer(for: Book.self, inMemory: true)
}

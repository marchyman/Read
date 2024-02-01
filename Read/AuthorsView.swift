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
    @State private var newAuthor = false
    var selectAction: (Author) -> ()

    init(selectAction: @escaping (Author) -> ()) {
        let sortDescriptors: [SortDescriptor] = [
            SortDescriptor<Author>(\.lastName, comparator: .localized),
            SortDescriptor<Author>(\.firstName, comparator: .localized)
        ]
        _authors = Query(sort: sortDescriptors)
        self.selectAction = selectAction
    }

    var body: some View {
        VStack( alignment: .leading) {
            if !authors.isEmpty {
                List(authors) { author in
                    Button {
                        selectAction(author)
                    } label: {
                        Text(author.name)
                    }
                    .buttonStyle(.plain)
                }
            }
            Button("Create New Author", systemImage: "plus",
                   action: { newAuthor = true })
                .buttonStyle(.bordered)
                .padding()
        }
        .sheet(isPresented: $newAuthor) {
            NewAuthorView()
        }
    }
}

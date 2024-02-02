//
//  AuthorPickerView.swift
//  Read
//
//  Created by Marco S Hyman on 1/30/24.
//

import SwiftData
import SwiftUI

struct AuthorPickerView: View {
    @Environment(\.modelContext) private var context
    @Query private var authors: [Author]
    @State private var selectedAuthor = "none"
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
                Picker("Author", selection: $selectedAuthor) {
                    Text("pick an author")
                        .tag("none")
                    ForEach(authors) {
                        Text($0.name)
                            .tag($0.name)
                    }
                    .pickerStyle(.wheel)
                }
                .onChange(of: selectedAuthor) {
                    if let author = authors.first(where: { $0.name == selectedAuthor}) {
                        selectAction(author)
                    }
                    selectedAuthor = "none"
                }
            }
            Button("Create New Author", systemImage: "plus",
                   action: { newAuthor = true })
                .buttonStyle(.bordered)
                .padding()
        }
        .padding()
        .sheet(isPresented: $newAuthor) {
            NewAuthorView()
        }
    }
}

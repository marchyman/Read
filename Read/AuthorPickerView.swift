//
//  AuthorPickerView.swift
//  Read
//
//  Created by Marco S Hyman on 1/30/24.
//

import SwiftData
import SwiftUI

private let addAuthor = "Add new author"

struct AuthorPickerView: View {
    @Environment(\.modelContext) private var context
    @Query private var authors: [Author]

    @State private var selectedAuthor = addAuthor
    @State private var newAuthor = false
    var selectAction: (Author) -> Void

    init(selectAction: @escaping (Author) -> Void) {
        let sortDescriptors: [SortDescriptor] = [
            SortDescriptor<Author>(\.lastName, comparator: .localized),
            SortDescriptor<Author>(\.firstName, comparator: .localized)
        ]
        _authors = Query(sort: sortDescriptors)
        self.selectAction = selectAction
    }

    var body: some View {
        HStack {
            Picker(selection: $selectedAuthor) {
                Text("Add new author")
                    .tag(addAuthor)
                ForEach(authors) {
                    Text($0.name)
                        .tag($0.name)
                }
            } label: {
                Text("Select author from list: ")
                    .font(.headline)
            }
            .pickerStyle(.menu)
            .frame(width: 350)
            .onChange(of: selectedAuthor) {
                if selectedAuthor == addAuthor {
                    newAuthor.toggle()
                } else {
                    if let author = authors.first(where: { $0.name == selectedAuthor}) {
                        selectAction(author)
                    }
                    selectedAuthor = ""
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $newAuthor) {
            NewAuthorView(selectedAuthor: $selectedAuthor)
        }
    }
}

#Preview {
    Form {
        Section("Authors") {
            AuthorPickerView(selectAction: { _ in })
                .modelContainer(Book.preview)
        }
    }
}

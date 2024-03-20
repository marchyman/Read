//
//  AuthorPickerView.swift
//  Read
//
//  Created by Marco S Hyman on 1/30/24.
//

import SwiftData
import SwiftUI

fileprivate let none = "none"

struct AuthorPickerView: View {
    @Environment(\.modelContext) private var context
    @Query private var authors: [Author]

    @State private var selectedAuthor = none
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
        HStack {
            if !authors.isEmpty {
                Picker("Select author(s)", selection: $selectedAuthor) {
                    Text("Anonymous")
                        .tag(none)
                    ForEach(authors) {
                        Text($0.name)
                            .tag($0.name)
                    }
//                    .pickerStyle(.wheel)
                }
                .frame(width: 300)
                .onChange(of: selectedAuthor) {
                    if selectedAuthor != none {
                        if let author = authors.first(where: { $0.name == selectedAuthor}) {
                            selectAction(author)
                        }
                        selectedAuthor = none
                    }
                }
            }
            Spacer()
            Button("Add new author", systemImage: "plus",
                   action: { newAuthor = true })
                .buttonStyle(.bordered)
                .padding()
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

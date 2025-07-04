//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

struct BookFormView: View {
    @Binding var title: String
    @Binding var selectedAuthors: [Author]
    @Binding var seriesName: String
    @Binding var seriesOrder: Int

    enum FocusableFields: Hashable {
        case title
        case authors
    }

    @FocusState private var focusedField: FocusableFields?

    var body: some View {
        Form {
            Section("Title") {
                TitleGroupView(title: $title)
            }

            Section("Author(s)") {
                if selectedAuthors.isEmpty {
                    Text("Please select one or more authors")
                } else {
                    List {
                        ForEach(selectedAuthors) { author in
                            Text(author.name)
                                .font(.title2)
                        }
                        .onDelete { indexSet in
                            withAnimation {
                                for index in indexSet {
                                    selectedAuthors.remove(at: index)
                                }
                            }
                        }
                    }
                }
                AuthorPickerView(selectAction: selectAuthor)
            }

            Section("Series") {
                SeriesGroupView(
                    seriesName: $seriesName,
                    seriesOrder: $seriesOrder)
            }
        }
        .cornerRadius(10)
        .onAppear {
            focusedField = .title
        }
    }

    func selectAuthor(_ author: Author) {
        if !selectedAuthors.map({ $0.id }).contains(author.id) {
            selectedAuthors.append(author)
        }
    }
}

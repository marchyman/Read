//
//  NewBookView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftUI
import SwiftData

struct NewBookView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    // create state variables for each field of a book, author, and series.
    // A new book will be created from this state when the user selects the
    // add button.  An instance of a Book can not be used due to its many
    // optional fields.
    @State private var release: Date = .now
    @State private var title: String = ""
    @State private var authors: [Author] = []
    @State private var series: Series = Series(name: "")
    @State private var seriesOrder: Int = 0

    @State private var isFutureRelease = false

    var body: some View {
        VStack(alignment: .leading) {
            cancelOrAdd
            Form {
                Section("Title") {
                    TextField("title", text: $title)
                }
                Section("Author(s)") {
                    Text("Add/Select authors here")
                }
                Section("Series") {
                    TextField("series name", text: $series.name)
                    if series.name != "" {
                        LabeledContent {
                            TextField("book number in series",
                                      value: $seriesOrder, format: .number)
                                .multilineTextAlignment(.trailing)
                        } label: {
                            Text("Series order")
                        }
                    }
                }
                Toggle(isOn: $isFutureRelease) {
                    Text("Future release?")
                }
                if isFutureRelease {
                    LabeledContent {
                        DatePicker("", selection: $release,
                                   displayedComponents: .date)
                    } label: {
                        Text("Release Date")
                    }
                }
            }
            .cornerRadius(8)
            Spacer()
       }
        .padding()
    }

    var cancelOrAdd: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
            .padding(.horizontal)
            .buttonStyle(.bordered)
            Button {
                addBook()
            } label: {
                Text("Add New Book")
            }
            .buttonStyle(.borderedProminent)
            .disabled(title.isEmpty || authors.isEmpty)
        }
        .padding(.vertical)
    }

    func addBook() {
        let newBook = Book(title: title)
        if isFutureRelease {
            newBook.release = release
        }
        context.insert(newBook)

        // update authors
        newBook.authors = authors

        for author in authors {
            author.books?.append(newBook)
        }

        // update series
        if series.name != "" {
            newBook.series = series
            newBook.seriesOrder = seriesOrder
            series.books?.append(newBook)
        }

        // save changes and dismiss
        try? context.save()
        // show error when save throws
        dismiss()
    }
}

#Preview {
    NewBookView()
}

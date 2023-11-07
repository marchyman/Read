//
//  NewBookView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftUI

struct NewBookView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var series = ""
    @State private var seriesOrder = 1
    @State private var isFutureRelease = false
    @State private var estRelease = Date.now

    var body: some View {
        VStack(alignment: .leading) {
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
                .disabled(title.isEmpty || author.isEmpty)
            }
            .padding(.vertical)

            LabeledContent {
                TextField("title", text: $title)
            } label: {
                Text("Title")
            }
            LabeledContent {
                TextField("authors, separated by comma", text: $author)
            } label: {
                Text("Author")
            }
            LabeledContent {
                TextField("series name", text: $series)
            } label: {
                Text("Series")
            }
            if !series.isEmpty {
                LabeledContent {
                    TextField("book number in series",
                              value: $seriesOrder, format: .number)
                } label: {
                    Text("Series order")
                }
            }
            Divider()
            Toggle(isOn: $isFutureRelease) {
                Text("Future release?")
            }
            if isFutureRelease {
                LabeledContent {
                    DatePicker("", selection: $estRelease,
                               displayedComponents: .date)
                } label: {
                    Text("Est Release Date")
                }
            }
            Spacer()
       }
        .padding()
        .textFieldStyle(.roundedBorder)
    }

    func addBook() {
        let newBook = Book(title: title, author: author)
        if !series.isEmpty {
            newBook.series = series
            newBook.seriesOrder = seriesOrder
        }
        if isFutureRelease {
            newBook.estRelease = estRelease
        }
        context.insert(newBook)
        dismiss()
    }
}

#Preview {
    NewBookView()
}

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

            TitleFieldView(title: $title)
            AuthorFieldView(author: $author)
            SeriesFieldView(series: $series)
            if !series.isEmpty {
                SeriesOrderFieldView(seriesOrder: $seriesOrder)
            }
            Divider()
            Toggle(isOn: $isFutureRelease) {
                Text("Future release?")
            }
            if isFutureRelease {
                EstReleasePickerView(estRelease: $estRelease)
            }
            Spacer()
       }
        .padding()
        .textFieldStyle(.roundedBorder)
    }

    func addBook() {
        let newBook = Book(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        if !series.isEmpty {
            newBook.series = series.trimmingCharacters(in: .whitespacesAndNewlines)
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

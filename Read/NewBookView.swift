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
    @Query private var series: [Series]


    // create state variables for each field of a book, author, and series.
    // A new book will be created from this state when the user selects the
    // add button.  An instance of a Book can not be used due to its many
    // optional fields.
    @State private var release: Date = .now
    @State private var title: String = ""
    @State private var authors: Set<UUID> = []
    @State private var seriesName: String = ""
    @State private var seriesOrder: Int = 0

    @State private var selectAuthors = false
    @State private var selectSeries = false
    @State private var autoselectSeries = false
    @State private var seriesMatches: [String] = []
    @State private var isFutureRelease = false

    enum FocusableFields: Hashable {
        case title
        case authors
        case series
        case seriesOrder
        case release
    }

    @FocusState private var focusedField: FocusableFields?

    var body: some View {
        VStack(alignment: .leading) {
            cancelOrAdd
            Form {
                Section("Title") {
                    TextField("title", text: $title)
                        .focused($focusedField, equals: .title)
                }
                Section("Author(s)") {
                    DisclosureGroup("Select author",
                                    isExpanded: $selectAuthors) {
                        AuthorsView(selectedAuthors: $authors)
                    }
                }
                Section("Series") {
                    DisclosureGroup("Add/Select series",
                                    isExpanded: $selectSeries) {
                        TextField("series name", text: $seriesName)
                            .focused($focusedField, equals: .series)
                            .popover(isPresented: $autoselectSeries) {
                                VStack(alignment: .leading) {
                                    ForEach(seriesMatches, id: \.self) { match in
                                        Button {
                                            seriesName = match
                                            focusedField = .seriesOrder
                                        } label: {
                                            Text(match)
                                                .font(.title)
                                        }
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: seriesName) {
                                if seriesName.count > 1 {
                                    seriesMatches = lookups(prefix: seriesName)
                                    autoselectSeries = !seriesMatches.isEmpty
                                } else {
                                    autoselectSeries = false
                                }
                            }
                            .onChange(of: focusedField) {
                                autoselectSeries = false
                            }
                        LabeledContent {
                            TextField("book number in series",
                                      value: $seriesOrder, format: .number)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .seriesOrder)
                        } label: {
                            Text("Series order")
                        }
                    }
                }
                Section("Release Date") {
                    DisclosureGroup("Select optional future release date",
                                     isExpanded: $isFutureRelease) {
                        LabeledContent {
                            DatePicker("", selection: $release,
                                       displayedComponents: .date)
                                .focused($focusedField, equals: .release)
                        } label: {
                            Text("Release Date")
                        }
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
            .disabled(title.isEmpty /* || authors.isEmpty */)
        }
        .padding(.vertical)
    }

    func lookups(prefix: String) -> [String] {
        let lowercasedPrefix = prefix.lowercased()
        return series
            .map { $0.name }
            .filter { $0.lowercased().hasPrefix(lowercasedPrefix) }
    }

    func addBook() {
        let newBook = Book(title: title)
        if isFutureRelease {
            newBook.release = release
        }
        context.insert(newBook)

        // update authors
//        newBook.authors = authors
//        for author in authors {
//            author.books?.append(newBook)
//        }

        // update series (what if the series already exists, i.e. you
        // screwed up
//        if series.name != "" {
//            context.insert(series)
//            newBook.series = series
//            newBook.seriesOrder = seriesOrder
//            series.books?.append(newBook)
//        }

        // save changes and dismiss
        try? context.save()
        // show error when save throws
        dismiss()
    }
}

#Preview {
    NewBookView()
}

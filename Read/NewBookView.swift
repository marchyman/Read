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
    @State private var selectedAuthors: [Author] = []
    @State private var seriesName: String = ""
    @State private var seriesOrder: Int = 0

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
            CancelOrAddView(addText: "Add New Book",
                            addFunc: addBook,
                            disabled: { title.isEmpty })
            Form {
                Section("Title") {
                    TextField("title", text: $title)
                        .focused($focusedField, equals: .title)
                        .onSubmit {
                            focusedField = .authors
                        }
                }
                Section("Author(s)") {
                    if selectedAuthors.isEmpty {
                        Text("Please select one or more authors")
                    } else {
                        List {
                            ForEach(selectedAuthors) { author in
                                Text(author.name)
                            }
                            .onDelete {indexSet in
                                withAnimation {
                                    for index in indexSet {
                                        selectedAuthors.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                    AuthorsView(selectAction: selectAuthor)
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
        .onAppear {
            focusedField = .title
        }
    }

    func selectAuthor(_ author: Author) {
        if !selectedAuthors.map({ $0.id }).contains(author.id) {
            selectedAuthors.append(author)
        }
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

        // update and/or create entry for series if needed
        if seriesName != "" {
            var aSeries: Series
            if let existingSeries = series.first(where: { $0.name == seriesName } ) {
                aSeries = existingSeries
            } else {
                aSeries = Series(name: seriesName)
                context.insert(aSeries)
            }

            newBook.series = aSeries
            newBook.seriesOrder = seriesOrder
            aSeries.books?.append(newBook)
        }

        // save changes and dismiss
        do {
            try context.save()
        } catch {
            fatalError("NewBookView context.save")
        }
        dismiss()
    }
}

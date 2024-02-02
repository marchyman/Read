//
//  EditBookView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftUI
import SwiftData

struct EditBookView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query private var series: [Series]

    @Bindable var book: Book

    // create state variables for each field of a book, author, and series.
    // Initial values will be set from the above book when the view appears
    // and written back to the book when the update button is pressed.
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
            HStack {
                Spacer()
                Button {
                    updateBook()
                } label: {
                    Text("Update Book")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical)

            Form {
                Section("Title") {
                    TextField("title", text: $title)
                        .focused($focusedField, equals: .title)
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
                    AuthorPickerView(selectAction: selectAuthor)
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

            // initialize fields from an existing book
            if book.release != nil {
                release = book.release!
                isFutureRelease = true
            } else {
                release = .now
            }
            title = book.title
            selectedAuthors = book.authors ?? []
            seriesName = book.series?.name ?? ""
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

    func updateBook() {
        // Update future release.  Make it nil when toggled off
        if isFutureRelease {
            book.release = release
        } else {
            book.release = nil
        }

        // Update any changes in authors
        if book.authors != selectedAuthors {
            print("there are differences im author")
        }

        if book.series == nil {
            if seriesName != "" {
                updateSeries()
            }
        } else if book.series?.name != seriesName {
            // series name changed or was removed
            if seriesName == "" {
                // remove series
                book.series = nil
                book.seriesOrder = nil
            } else {
                // series changed
                updateSeries()
            }
        } else if book.seriesOrder != seriesOrder {
            // only the series order changed
            book.seriesOrder = seriesOrder
        }

        // save changes and dismiss
        do {
            try context.save()
        } catch {
            fatalError("NewBookView context.save")
        }
    }

    func updateSeries() {
        var aSeries: Series

        if let existingSeries = series.first(where: { $0.name == seriesName } ) {
            aSeries = existingSeries
        } else {
            aSeries = Series(name: seriesName)
            context.insert(aSeries)
        }

        book.series = aSeries
        book.seriesOrder = seriesOrder
        aSeries.books?.append(book)
    }
}

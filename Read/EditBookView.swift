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
//    @Query private var series: [Series]

    var book: Book

    // create state variables for each field of a book, author, and series.
    // Initial values will be set from the above book when the view appears
    // and written back to the book when the update button is pressed.
    @State private var title: String = ""
    @State private var selectedAuthors: [Author] = []
    @State private var selectSeries = false
    @State private var seriesName: String = ""
    @State private var seriesOrder: Int = 0
    @State private var isFutureRelease = false
//    @State private var release: Date = .now

    enum FocusableFields: Hashable {
        case title
        case authors
        case release
    }

    @FocusState private var focusedField: FocusableFields?

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section("Title") {
                    TextField("title", text: $title)
                        .font(.title2)
                        .focused($focusedField, equals: .title)
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
                    DisclosureGroup(isExpanded: $selectSeries) {
                        SeriesGroupView(seriesName: $seriesName,
                                        seriesOrder: $seriesOrder)
                    } label: {
                        Text("Edit Series")
                            .font(.title2)
                    }
                }

                Section("Release Date") {
                    DisclosureGroup(isExpanded: $isFutureRelease) {
                        Text("Future release date editing not yet available")
//                        LabeledContent {
//                            DatePicker("", selection: $release,
//                                       displayedComponents: .date)
//                            .focused($focusedField, equals: .release)
//                        } label: {
//                            Text("Release Date")
//                                .font(.title2)
//                        }
                    } label: {
                        Text("Select optional future release date")
                            .font(.title2)
                    }
                }
            }
            .cornerRadius(10)
            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = .title

            // initialize fields from an existing book
            title = book.title
            selectedAuthors = book.authors
            seriesName = book.series?.name ?? ""
            seriesOrder = book.seriesOrder ?? 0
//            if book.release != nil {
//                release = book.release!
//                isFutureRelease = true
//            } else {
//                release = .now
//            }
        }
        .navigationTitle("Edit book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                updateBook()
            } label: {
                Text("Update Book")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    func selectAuthor(_ author: Author) {
        if !selectedAuthors.map({ $0.id }).contains(author.id) {
            selectedAuthors.append(author)
        }
    }

    func updateBook() {
        // Update future release.  Make it nil when toggled off
//        if isFutureRelease {
//            book.release = release
//        } else {
//            book.release = nil
//        }
//
        // Update any changes in authors
        if book.authors != selectedAuthors {
            updateAuthors()
        }

//        if book.series == nil {
//            if seriesName != "" {
//                updateSeries()
//            }
//        } else if book.series?.name != seriesName {
//            // series name changed or was removed
//            if seriesName == "" {
//                // remove series
//                book.series = nil
//                book.seriesOrder = nil
//            } else {
//                // series changed
//                updateSeries()
//            }
//        } else if book.seriesOrder != seriesOrder {
//            // only the series order changed
//            book.seriesOrder = seriesOrder
//        }

        // save changes
        do {
            try context.save()
        } catch {
            fatalError("NewBookView context.save")
        }
    }

//    func updateSeries() {
//        var aSeries: Series
//
//        if let existingSeries = series.first(where: { $0.name == seriesName } ) {
//            aSeries = existingSeries
//        } else {
//            aSeries = Series(name: seriesName)
//            context.insert(aSeries)
//        }
//
//        book.series = aSeries
//        book.seriesOrder = seriesOrder
//        aSeries.books?.append(book)
//    }

    func updateAuthors() {
        // remove any authors from the book that are not in selectedAuthors
        for author in book.authors {
            if !selectedAuthors.map({$0.id}).contains(author.id) {
                if let i = book.authors.firstIndex(where: {$0.id == author.id}) {
                    book.authors.remove(at: i)
                }
            }
        }
        // add authors from selectedAuthors
        for author in selectedAuthors {
            if !book.authors.map({$0.id}).contains(author.id) {
                book.authors.append(author)
                author.books.append(book)
            }
        }
    }
}

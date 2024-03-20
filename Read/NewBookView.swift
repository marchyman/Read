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
    // add button.
    @State private var release: Date = .now
    @State private var title: String = ""
    @State private var selectedAuthors: [Author] = []
    @State private var seriesName: String = ""
    @State private var seriesOrder: Int = 0

    @State private var selectSeries = false
    @State private var isFutureRelease = false

    enum FocusableFields: Hashable {
        case title
        case authors
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
                    DisclosureGroup("Select optional future release date",
                                    isExpanded: $isFutureRelease) {
                        LabeledContent {
                            DatePicker("", selection: $release,
                                       displayedComponents: .date)
                            .font(.title2)
                            .focused($focusedField, equals: .release)
                        } label: {
                            Text("Release Date")
                                .font(.title2)
                        }
                    }
                }
            }
            .cornerRadius(10)
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

    func addBook() {
        let newBook = Book(title: title)
        if isFutureRelease {
            newBook.release = release
        }
        context.insert(newBook)

        // update authors
        newBook.authors = selectedAuthors
        for author in selectedAuthors {
            author.books.append(newBook)
        }

        // update and/or create entry for series if needed
        if seriesName != "" {
            updateSeries(newBook)
        }

        // save changes and dismiss
        do {
            try context.save()
        } catch {
            fatalError("NewBookView context.save")
        }
        dismiss()
    }

    func updateSeries(_ book: Book) {
        var aSeries: Series

        if let existingSeries = series.first(where: { $0.name == seriesName } ) {
            aSeries = existingSeries
        } else {
            aSeries = Series(name: seriesName)
            context.insert(aSeries)
        }

        book.series = aSeries
        book.seriesOrder = seriesOrder
        aSeries.books.append(book)
    }

}

#Preview {
    NewBookView()
        .modelContainer(Book.preview)
}

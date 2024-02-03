//
//  BookDetailView.swift
//  Read
//
//  Created by Marco S Hyman on 1/29/24.
//

import SwiftData
import SwiftUI

struct BookDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var book: Book
    @State private var seriesName: String = ""

    var body: some View {
        VStack {
            Form {
                TextField("Title", text: $book.title)
                if !book.authors.isEmpty {
                    List {
                        Text("Authors:")
                        ForEach(book.authors) { author in
                            Text(author.name)
                        }
                        .onDelete { indexSet in
                            withAnimation {
                                for index in indexSet {
                                    book.authors.remove(at: index)
                                }
                            }
                        }
                        Text("add author here!!")
                    }
                } else {
                    Text("Author: unknown")
                }
                TextField("Series:", text: $seriesName)
                TextField("Series Order:", value: $book.seriesOrder, format: .number)
                //            LabeledContent {
                //                DatePicker("", selection: $book.release,
                //                           displayedComponents: .date)
                //            } label: {
                //                Text("Release Date")
                //            }
                Text("Date added: \(book.added.formatted(date: .abbreviated, time: .omitted))")
            }
            .padding()
            .navigationTitle("Book Information")
            .onAppear {
                seriesName = book.series?.name ?? ""
            }
        }
        .padding()
    }
}

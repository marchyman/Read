//
//  EditBookView.swift
//  Read
//
//  Created by Marco S Hyman on 11/7/23.
//

import SwiftUI
import SwiftData

struct EditBookView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Bindable var book: Book
    @State private var estRelease = Date.now
    @State private var isFutureRelease = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Dismiss")
                }
                .padding(.horizontal)
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical)

            LabeledContent {
                TextField("title", text: $book.title)
            } label: {
                Text("Title")
            }
            LabeledContent {
                TextField("authors, separated by comma", text: $book.author)
            } label: {
                Text("Author")
            }
            LabeledContent {
                TextField("series name", text: $book.series.bound)
            } label: {
                Text("Series")
            }
            if !book.series.bound.isEmpty {
                LabeledContent {
                    TextField("book number in series",
                              value: $book.seriesOrder, format: .number)
                } label: {
                    Text("Series order")
                }
            }
            Divider()
            Toggle(isOn: $isFutureRelease) {
                Text("Future release?")
            }
            .onChange(of: isFutureRelease) {
                book.estRelease = isFutureRelease ? estRelease : nil

            }
            if isFutureRelease {
                LabeledContent {
                    DatePicker("", selection: $estRelease,
                               displayedComponents: .date)
                    .onChange(of: estRelease) {
                        book.estRelease = estRelease
                    }
                } label: {
                    Text("Est Release Date")
                }
            }
            Spacer()
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .onAppear() {
            isFutureRelease = book.estRelease != nil
            estRelease = book.estRelease ?? Date.now
        }
    }
}

// needed to bind to an optional string

extension Optional where Wrapped == String {
    var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}

//#Preview {
//    EditBookView()
//}

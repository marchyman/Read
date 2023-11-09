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
    @State private var seriesOrder = 0
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

            TitleFieldView(title: $book.title)
            AuthorFieldView(author: $book.author)
                .onChange(of: book.author) {
                    book.updateAuthors()
                }
            SeriesFieldView(series: $book.series.bound)
                .onChange(of: book.series) {
                    if book.series == nil {
                        book.seriesOrder = nil
                    }
                }
            if !book.series.bound.isEmpty {
                SeriesOrderFieldView(seriesOrder: $seriesOrder)
                    .onChange(of: seriesOrder) {
                        book.seriesOrder = seriesOrder
                    }
            }
            Divider()
            FutureReleaseToggleView(isFutureRelease: $isFutureRelease)
                .onChange(of: isFutureRelease) {
                    book.estRelease = isFutureRelease ? estRelease : nil
                }
            if isFutureRelease {
                EstReleasePickerView(estRelease: $estRelease)
                    .onChange(of: estRelease) {
                        book.estRelease = estRelease
                    }
            }
            Spacer()
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .onAppear() {
            seriesOrder = book.seriesOrder ?? 1
            isFutureRelease = book.estRelease != nil
            estRelease = book.estRelease ?? Date.now
        }
    }
}


//#Preview {
//    EditBookView()
//}

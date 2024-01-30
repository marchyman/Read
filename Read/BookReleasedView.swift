//
//  BookReleasedView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftData
import SwiftUI

struct BookReleasedView: View {
    @Environment(\.dismiss) var dismiss

    var book: Book
    var body: some View {
        VStack {
            Text("Mark book as released?")
            Button {
                book.release = nil
                dismiss()
            } label: {
                Text("Released")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Book.self, configurations: config)
//        let book = Book(title: "Preview Book", author: "Preview Author")
//
//        return BookReleasedView(book: book)
//            .modelContainer(container)
//    } catch {
//        return Text("Preview failed: \(error.localizedDescription)")
//    }
//}

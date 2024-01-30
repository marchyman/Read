//
//  BookDetailView.swift
//  Read
//
//  Created by Marco S Hyman on 1/29/24.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book

    var body: some View {
        Text("Book: \(book.title)")
            .navigationTitle("Book Information")
    }
}

#Preview {
    BookDetailView(book: Book(title: "A Test Book"))
}

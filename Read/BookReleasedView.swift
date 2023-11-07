//
//  BookReleasedView.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import SwiftUI

struct BookReleasedView: View {
    @Environment(\.dismiss) var dismiss

    var book: Book
    var body: some View {
        VStack {
            Text("Mark book as released?")
            Button {
                book.estRelease = nil
                dismiss()
            } label: {
                Text("Released")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

//#Preview {
//    BookReleasedView()
//}

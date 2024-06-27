//
//  TitleGroupView.swift
//  Read
//
//  Created by Marco S Hyman on 3/19/24.
//

import SwiftData
import SwiftUI

struct TitleGroupView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Book>(\.title)]) private var books: [Book]

    @Binding var title: String

    @State private var showMatchingTitles = false
    @State private var matchingTitles: [String] = []

    enum FocusableFields: Hashable {
        case title
    }

    var body: some View {
        Group {
            TextField("title", text: $title)
                .font(.title2)
                .popover(isPresented: $showMatchingTitles) {
                    List(matchingTitles, id: \.self) { title in
                        Text(title)
                            .font(.title2)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding()
                    .frame(width: 500, height: 250, alignment: .leading)
                }
                .onChange(of: title) {
                    if title.count > 1 {
                        matchingTitles = books.map { $0.title }
                            .filter {
                                $0.localizedStandardContains(title)
                            }
                        showMatchingTitles = !matchingTitles.isEmpty
                    } else {
                        showMatchingTitles = false
                    }
                }
        }
    }
}

#Preview {
    TitleGroupView(title: .constant(""))
        .modelContainer(Book.preview)
}

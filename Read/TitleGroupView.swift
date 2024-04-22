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

    @FocusState private var focusedField: FocusableFields?

    var body: some View {
        Group {
            TextField("title", text: $title)
                .font(.title2)
                .focused($focusedField, equals: .title)
                .popover(isPresented: $showMatchingTitles) {
                    VStack(alignment: .leading) {
                        ForEach(matchingTitles, id: \.self) { title in
                            Text(title)
                                .font(.title2)
                        }
                    }
                    .padding()
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
                .onChange(of: focusedField) {
                    showMatchingTitles = false
                }
        }
        .onAppear {
            focusedField = .title
        }
    }
}

#Preview {
    TitleGroupView(title: .constant(""))
        .modelContainer(Book.preview)
}

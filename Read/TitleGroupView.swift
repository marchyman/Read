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
                    ScrollView {
                        ForEach(matchingTitles, id: \.self) { title in
                            HStack {
                                Text(title)
                                    .font(.title2)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: 400)
                    }
                    .frame(maxHeight: 400)
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
        }
    }
}

#Preview {
    TitleGroupView(title: .constant(""))
        .modelContainer(Book.preview)
}

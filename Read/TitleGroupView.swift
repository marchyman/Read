//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct TitleGroupView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store

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
                    .presentationCompactAdaptation(.popover)
                }
                .onChange(of: title) {
                    if title.count > 1 {
                        matchingTitles = store.books.map { $0.title }
                            .filter {
                                $0.localizedStandardContains(title)
                            }
                        if matchingTitles.count == 1 &&
                            title == matchingTitles[0] {
                            showMatchingTitles = false
                        } else {
                            showMatchingTitles = !matchingTitles.isEmpty
                        }
                    } else {
                        showMatchingTitles = false
                    }
                }
        }
    }
}

#Preview {
    TitleGroupView(title: .constant(""))
        .environment(Store(initialState: BookState(forPreview: true,
                                                   addTestData: true),
                           reduce: ModelReducer()))
}

//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

enum DataViews: CaseIterable, @MainActor Identifiable, View {
    case byTitle
    case byAuthor
    case bySeries

    var id: Self { self }

    var body: some View {
        switch self {
        case .byTitle:
            BooksByTitleView()
        case .byAuthor:
            BooksByAuthorView()
        case .bySeries:
            BooksBySeriesView()
        }
    }

    var searchPrompt: String {
        switch self {
        case .byTitle: "Title search"
        case .byAuthor: "Author search"
        case .bySeries: "Series search"
        }
    }

    var pickerLabel: String {
        switch self {
        case .byTitle: "By Title"
        case .byAuthor: "By Author"
        case .bySeries: "By Series"
        }
    }
}

struct SelectView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store
    @State private var path = NavigationPath()
    @State private var dataView = DataViews.byTitle
    @State private var showLog = false

    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                dataView
                    .navigationDestination(for: Book.self) { book in
                        EditBookView(book: book) {
                            path.removeLast()
                        }
                    }
            }
            HStack {
                StatsView()
                    .padding(.bottom, 8)
                    .onTapGesture {
                        showLog.toggle()
                    }
                    .sheet(isPresented: $showLog) { LogView() }

                Spacer()

                Picker("Books, Authors, Series",
                       selection: $dataView) {
                    ForEach(DataViews.allCases) { dataView in
                        Text(dataView.pickerLabel)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding()
        }
    }
}

#Preview {
    SelectView()
        .environment(Store(initialState: BookState(forPreview: true,
                                                   addTestData: true),
                           reduce: ModelReducer()))
}

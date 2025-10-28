//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF

struct EditSeriesView: View {
    @Environment(Store<BookState, ModelEvent>.self) var store
    @Environment(\.dismiss) private var dismiss

    let series: Series

    @State private var name = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button {
                    if series.name != name {
                        store.send(.editSeriesDone(series, name))
                    }
                    dismiss()
                } label: {
                    Text("done")
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
            }
            Form {
                TextField("Series name", text: $name)
                    .cornerRadius(8)
            }
            .cornerRadius(8)
            Spacer()
        }
        .padding()
        .onAppear {
            name = series.name
        }
    }
}

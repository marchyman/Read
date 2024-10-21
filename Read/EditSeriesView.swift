//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import SwiftUI
import SwiftData

struct EditSeriesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var series: Series

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("done")
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
            }
            Form {
                TextField("Series name", text: $series.name)
                    .cornerRadius(8)
            }
            .cornerRadius(8)
            Spacer()
        }
        .padding()
    }
}

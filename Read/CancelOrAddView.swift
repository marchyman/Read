//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

struct CancelOrAddView: View {
    @Environment(\.dismiss) var dismiss

    let addText: String
    let addFunc: () -> Void
    let disabled: () -> Bool

    var body: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
            .padding(.horizontal)
            .buttonStyle(.bordered)
            Button {
                addFunc()
            } label: {
                Text(addText)
            }
            .buttonStyle(.borderedProminent)
            .disabled(disabled())
        }
        .padding(.vertical)
    }
}

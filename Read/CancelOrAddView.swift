//
//  CancelOrAddView.swift
//  Read
//
//  Created by Marco S Hyman on 1/31/24.
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

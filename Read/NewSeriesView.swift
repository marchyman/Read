//
//  NewSeriesView.swift
//  Read
//
//  Created by Marco S Hyman on 1/31/24.
//

import SwiftData
import SwiftUI

struct NewSeriesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query private var series: [Series]
    @State private var name: String = ""

    enum FocusableFields: Hashable {
        case name
    }

    @FocusState private var focusedField: FocusableFields?

    var body: some View {
        VStack(alignment: .leading) {
            CancelOrAddView(
                addText: "Add New Series",
                addFunc: addSeries,
                disabled: invalidSeries)
            Form {
                TextField("Series name", text: $name)
                    .focused($focusedField, equals: .name)
            }
            .cornerRadius(8)
            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = .name
        }
    }

    func invalidSeries() -> Bool {
        guard !name.isEmpty else { return true }
        let match = series.first(where: { $0.name == name })
        return match != nil

    }
    func addSeries() {
        let series = Series(name: name)
        context.insert(series)
        do {
            try context.save()
        } catch {
            fatalError("NewSeriesView context.save")
        }
        dismiss()
    }
}

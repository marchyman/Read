//
//  SeriesGroupView.swift
//  Read
//
//  Created by Marco S Hyman on 2/2/24.
//

import SwiftData
import SwiftUI

struct SeriesGroupView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Series>(\.name)]) private var series: [Series]

    @Binding var seriesName: String
    @Binding var seriesOrder: Int

    @State private var autoselectSeries = false
    @State private var seriesMatches: [String] = []

    enum FocusableFields: Hashable {
        case series
        case seriesOrder
    }

    @FocusState private var focusedField: FocusableFields?

    var body: some View {
        HStack {
            
            TextField("series name", text: $seriesName)
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .series)
                .popover(isPresented: $autoselectSeries) {
                    List(seriesMatches, id: \.self) { match in
                            Button {
                                seriesName = match
                                focusedField = .seriesOrder
                            } label: {
                                Text(match)
                                    .font(.title2)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                    }
                    .padding()
                    .frame(width: 500, height: 250, alignment: .leading)
                }
                .onChange(of: seriesName) {
                    if seriesName.count > 1 {
                        seriesMatches = lookups(prefix: seriesName)
                        autoselectSeries = !seriesMatches.isEmpty
                    } else {
                        autoselectSeries = false
                    }
                }
                .onChange(of: focusedField) {
                    if focusedField == .seriesOrder {
                        autoselectSeries = false
                    }
                }
            
            LabeledContent {
                TextField("#",
                          value: $seriesOrder, format: .number)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .seriesOrder)
            } label: {
                Text("Series order: ")
                    .font(.headline)
                    .frame(width: 100)
            }
            .frame(width: 160)
        }
    }

    func lookups(prefix: String) -> [String] {
        return series
            .map { $0.name }
            .filter { $0.localizedStandardContains(prefix) }
    }

}

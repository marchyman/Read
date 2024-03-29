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
        Group {
            TextField("series name", text: $seriesName)
                .font(.title2)
                .focused($focusedField, equals: .series)
                .popover(isPresented: $autoselectSeries) {
                    VStack(alignment: .leading) {
                        ForEach(seriesMatches, id: \.self) { match in
                            Button {
                                seriesName = match
                                focusedField = .seriesOrder
                            } label: {
                                Text(match)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding()
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
                    autoselectSeries = false
                }
            LabeledContent {
                TextField("book number in series",
                          value: $seriesOrder, format: .number)
                .font(.title2)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .seriesOrder)
            } label: {
                Text("Series order")
                    .font(.title2)
            }
        }
        .onAppear {
            focusedField = .series
        }
    }

    func lookups(prefix: String) -> [String] {
        let lowercasedPrefix = prefix.lowercased()
        return series
            .map { $0.name }
            .filter { $0.lowercased().hasPrefix(lowercasedPrefix) }
    }

}

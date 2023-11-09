//
//  BookFieldViews.swift
//  Read
//
//  Created by Marco S Hyman on 11/9/23.
//

// edit fields used to enter new books and edit existing books

import SwiftUI

private let width = 120.0

struct TitleFieldView: View {
    @Binding var title: String

    var body: some View {
        LabeledContent {
            TextField("title", text: $title)
        } label: {
            Text("Title")
                .frame(minWidth: width, alignment: .trailing)
        }
    }
}

struct AuthorFieldView: View {
    @Binding var author: String

    var body: some View {
        LabeledContent {
            TextField("authors, separated by comma", text: $author)
        } label: {
            Text("Author")
                .frame(minWidth: width, alignment: .trailing)
        }
    }
}

struct SeriesFieldView: View {
    @Binding var series: String

    var body: some View {
        LabeledContent {
            TextField("series name", text: $series)
        } label: {
            Text("Series")
                .frame(minWidth: width, alignment: .trailing)
        }
    }
}

struct SeriesOrderFieldView: View {
    @Binding var seriesOrder: Int

    var body: some View {
        LabeledContent {
            TextField("book number in series",
                      value: $seriesOrder, format: .number)
        } label: {
            Text("Series order")
                .frame(minWidth: width, alignment: .trailing)
        }
    }
}

struct FutureReleaseToggleView: View {
    @Binding var isFutureRelease: Bool

    var body: some View {
        Toggle(isOn: $isFutureRelease) {
            Text("Future release?")
        }
    }
}
struct EstReleasePickerView: View {
    @Binding var estRelease: Date

    var body: some View {
        LabeledContent {
            DatePicker("", selection: $estRelease,
                       displayedComponents: .date)
        } label: {
            Text("Est Release Date")
        }
    }
}

// Used when it is needed to bind to an optional String in TextFields

extension Optional where Wrapped == String {
    var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}

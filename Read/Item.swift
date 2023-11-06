//
//  Item.swift
//  Read
//
//  Created by Marco S Hyman on 11/6/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

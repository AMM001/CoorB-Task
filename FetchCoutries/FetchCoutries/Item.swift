//
//  Item.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

//
//  BucketItem.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.12.2023.
//

import Foundation

struct BucketItem: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    var count: Int
    
    static let limit: Int = 10
    
    mutating func updateCount(_ newCount: Int) {
        self.count = newCount
    }
}

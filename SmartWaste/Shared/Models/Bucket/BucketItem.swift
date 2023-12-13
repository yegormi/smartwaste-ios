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
    let categories: [BucketCategory]
        
    mutating func decrement() {
        self.count -= 1
    }
    
    mutating func increment() {
        self.count += 1
    }
}

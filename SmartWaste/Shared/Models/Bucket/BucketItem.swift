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
}

extension BucketItem {
    mutating func decrement() {
        self.count -= 1
    }
    
    mutating func increment() {
        self.count += 1
    }
}

extension BucketItem {
    func toState() -> BucketItemFeature.State {
        return .init(
            id: self.id,
            name: self.name,
            categories: self.categories,
            counter: .init(min: 0, max: 10, value: self.count)
        )
    }
}

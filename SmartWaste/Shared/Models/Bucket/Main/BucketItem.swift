//
//  BucketItem.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.12.2023.
//

import Foundation

struct Bucket: Codable, Equatable {
    let items: [BucketItem]
}

struct BucketItem: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    var count: Int
    let categories: [BucketCategory]
}

extension BucketItem {
    func toState() -> BucketItemFeature.State {
        return .init(
            id: id,
            name: name,
            categories: categories,
            counter: .init(min: Constants.minCount, max: Constants.maxCount, value: count)
        )
    }
}

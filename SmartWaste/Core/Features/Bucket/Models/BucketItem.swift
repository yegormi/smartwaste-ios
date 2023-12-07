//
//  BucketItem.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import Foundation

struct BucketItem: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let categories: [BucketCategory]
}

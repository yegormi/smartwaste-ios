//
//  BucketItem.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import Foundation

struct BucketItem: Codable, Equatable {
    let id: String
    let name: String
    var count: Int = 0
    let categories: [Category]
    
    static let limit: Int = 10
}

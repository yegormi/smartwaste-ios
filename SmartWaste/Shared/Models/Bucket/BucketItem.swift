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
    let count: Int
}

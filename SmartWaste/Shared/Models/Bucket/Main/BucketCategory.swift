//
//  BucketCategory.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.12.2023.
//

import Foundation

struct BucketCategory: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
    let emoji: String
}

//
//  Category.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import Foundation

struct Category: Codable, Equatable {
    let id: Int
    let name: String
    let slug: String
    let emoji: String
}

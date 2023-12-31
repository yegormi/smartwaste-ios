//
//  Quest.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import Foundation

struct QuestList: Codable {
    let quests: [Quest]
}

struct Quest: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let score: Int
    let total: Int
    let completed: Int
    let categoryId: Int
    let category: BucketCategory
}

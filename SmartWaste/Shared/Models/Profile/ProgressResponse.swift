//
//  ProgressResponse.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 08.12.2023.
//

import Foundation

struct ProgressResponse: Codable, Equatable {
    let progresses: [ProgressEntity]

    struct ProgressEntity: Codable, Identifiable, Equatable {
        let id: Int
        let questId: Int
        let userId: Int
        let completed: Int
    }
}

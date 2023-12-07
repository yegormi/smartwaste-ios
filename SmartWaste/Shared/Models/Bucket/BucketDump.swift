//
//  BucketDump.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.12.2023.
//

import Foundation

struct BucketDump: Codable, Equatable {
    let items: [DumpEntity]
    
    struct DumpEntity: Codable, Equatable, Identifiable {
        let id: Int
        let count: Int
    }
}

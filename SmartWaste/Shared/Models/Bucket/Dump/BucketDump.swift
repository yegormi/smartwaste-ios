//
//  BucketDump.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.12.2023.
//

import Foundation

struct BucketDump: Codable, Equatable {
    let items: [DumpEntity]
    
    init(items: [DumpEntity]) {
        self.items = items
    }
    
    init(bucket: Bucket) {
        self.items = bucket.items.map { DumpEntity(id: $0.id, count: $0.count) }
    }
    
    init(bucket: [BucketItem]) {
        self.items = bucket.map { DumpEntity(id: $0.id, count: $0.count) }
    }
}

struct DumpEntity: Codable, Equatable, Identifiable {
    let id: Int
    let count: Int
}

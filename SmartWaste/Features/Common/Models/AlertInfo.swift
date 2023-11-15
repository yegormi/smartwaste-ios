//
//  AlertInfo.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 14.11.2023.
//

import Foundation

struct AlertInfo: Identifiable {
    var id = UUID()
    let title: String
    let description: String
}


//
//  User.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import Foundation

struct User: Codable, Equatable {
    let id: String
    let username: String
    let email: String
}

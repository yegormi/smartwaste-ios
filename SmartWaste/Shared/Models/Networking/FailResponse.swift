//
//  FailResponse.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.11.2023.
//

import Foundation

struct FailResponse: Codable, Equatable, Error {
    let code: String
    let message: String
}

//
//  ErrorTypes.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.11.2023.
//

import Foundation

enum ErrorTypes: Error {
    case networkError(Error)
    case decodingError(Error)
    case failedWithResponse(FailResponse)
    case imageConversionError
}

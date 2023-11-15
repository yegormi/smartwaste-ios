//
//  GetPointsAction.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 14.11.2023.
//

import Foundation

struct GetPointsAction {
    let token: String
    
    func call(completion: @escaping (Result<[Point], ErrorResponse>) -> Void) {
        NetworkManager.performRequest(
            baseURL: "https://smartwaste-api.azurewebsites.net",
            endpoint: "/points",
            requestType: .get,
            token: token,
            completion: completion
        )
    }
}

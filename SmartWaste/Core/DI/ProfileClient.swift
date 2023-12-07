//
//  ProfileClient.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.12.2023.
//

import Foundation
import ComposableArchitecture
import Alamofire

// MARK: - API client interface

// Typically this interface would live in its own module, separate from the live implementation.
// This allows the feature to compile faster since it only depends on the interface.

@DependencyClient
struct ProfileClient {
    var getQuests: @Sendable (_ token: String) async throws -> QuestList
}

extension DependencyValues {
    var profileClient: ProfileClient {
        get { self[ProfileClient.self] }
        set { self[ProfileClient.self] = newValue }
    }
}

// MARK: - Live API implementation

extension ProfileClient: DependencyKey, TestDependencyKey {
    static let liveValue = ProfileClient(
        getQuests: { token in
            let endpoint = "/self/quests"
            
            let headers: HTTPHeaders = [
                "Authorization": "\(token)"
            ]
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(baseUrl + endpoint,
                           method: .get,
                           headers: headers
                )
                .validate()
                .responseDecodable(of: QuestList.self) { response in
                    handleResponse(response, continuation)
                }
            }
        }
    )
}

// MARK: - Test Implementation

extension ProfileClient {
    static let testValue = Self()
}

// MARK: - Constants

extension ProfileClient {
    static let baseUrl = Constants.baseUrl
}


private func handleResponse<T>(_ response: AFDataResponse<T>, _ continuation: CheckedContinuation<T, Error>) {
    switch response.result {
    case .success(let value):
        continuation.resume(returning: value)
    case .failure(let error):
        if let data = response.data,
           let failResponse = try? JSONDecoder().decode(FailResponse.self, from: data) {
            continuation.resume(throwing: ErrorResponse.failedWithResponse(failResponse))
        } else {
            continuation.resume(throwing: error)
        }
    }
}

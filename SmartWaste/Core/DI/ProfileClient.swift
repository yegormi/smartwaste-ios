//
//  ProfileClient.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.12.2023.
//

import Alamofire
import ComposableArchitecture
import Foundation

// MARK: - API client interface

// Typically this interface would live in its own module, separate from the live implementation.
// This allows the feature to compile faster since it only depends on the interface.

@DependencyClient
struct ProfileClient {
    var getQuests: @Sendable () async throws -> QuestList
}

extension DependencyValues {
    var profileClient: ProfileClient {
        get { self[ProfileClient.self] }
        set { self[ProfileClient.self] = newValue }
    }
}

// MARK: - Live API implementation

extension ProfileClient: DependencyKey, TestDependencyKey {
    @Dependency(\.sessionClient) static var sessionClient
    static let session = sessionClient.current
    
    static let liveValue = ProfileClient(
        getQuests: {
            let endpoint = "/self/quests"

            return try await withCheckedThrowingContinuation { continuation in
                session.request(baseUrl + endpoint,
                           method: .get)
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
    case let .success(value):
        continuation.resume(returning: value)
    case let .failure(error):
        if let data = response.data,
           let failResponse = try? JSONDecoder().decode(FailResponse.self, from: data) {
            continuation.resume(throwing: ErrorTypes.failedWithResponse(failResponse))
        } else {
            continuation.resume(throwing: error)
        }
    }
}

//
//  MapClient.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 28.11.2023.
//

import Alamofire
import ComposableArchitecture
import Foundation

// MARK: - API client interface

// Typically this interface would live in its own module, separate from the live implementation.
// This allows the feature to compile faster since it only depends on the interface.

@DependencyClient
struct MapClient {
    var getPoints: @Sendable () async throws -> [MapPoint]
    var searchPoints: @Sendable (_ categories: [String]) async throws -> [MapPoint]
}

extension DependencyValues {
    var mapClient: MapClient {
        get { self[MapClient.self] }
        set { self[MapClient.self] = newValue }
    }
}

// MARK: - Live API implementation

extension MapClient: DependencyKey, TestDependencyKey {
    @Dependency(\.sessionClient) static var sessionClient
    static let session = sessionClient.current

    static let liveValue = MapClient(
        getPoints: {
            let endpoint = "/points"

            return try await withCheckedThrowingContinuation { continuation in
                session.request(baseUrl + endpoint,
                                method: .get)
                    .validate()
                    .responseDecodable(of: [MapPoint].self) { response in
                        handleResponse(response, continuation)
                    }
            }
        }, searchPoints: { categories in
            let endpoint = "/points"

            let parameters: Parameters = [
                "categories": categories,
            ]

            return try await withCheckedThrowingContinuation { continuation in
                session.request(baseUrl + endpoint,
                                method: .get,
                                parameters: parameters)
                    .validate()
                    .responseDecodable(of: [MapPoint].self) { response in
                        handleResponse(response, continuation)
                    }
            }
        }
    )
}

// MARK: - Test Implementation

extension MapClient {
    static let testValue = Self()
}

// MARK: - Constants

extension MapClient {
    static let baseUrl = Constants.baseUrl
}

private func handleResponse<T>(_ response: AFDataResponse<T>, _ continuation: CheckedContinuation<T, Error>) {
    switch response.result {
    case let .success(value):
        continuation.resume(returning: value)
    case let .failure(error):
        if let data = response.data,
           let failResponse = try? JSONDecoder().decode(FailResponse.self, from: data)
        {
            continuation.resume(throwing: ErrorTypes.failedWithResponse(failResponse))
        } else {
            continuation.resume(throwing: error)
        }
    }
}

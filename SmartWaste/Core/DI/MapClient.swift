//
//  MapClient.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 28.11.2023.
//

import Foundation
import ComposableArchitecture
import Alamofire

// MARK: - API client interface

// Typically this interface would live in its own module, separate from the live implementation.
// This allows the feature to compile faster since it only depends on the interface.

@DependencyClient
struct MapClient {
    var getPoints:    @Sendable (_ token: String) async throws -> [MapPoint]
    var searchPoints: @Sendable (_ token: String, _ categories: [String]) async throws -> [MapPoint]
}

extension DependencyValues {
    var mapClient: MapClient {
        get { self[MapClient.self] }
        set { self[MapClient.self] = newValue }
    }
}

// MARK: - Live API implementation

extension MapClient: DependencyKey, TestDependencyKey {
    static let liveValue = MapClient(
        getPoints: { token in
            let endpoint = "/points"
            
            let headers: HTTPHeaders = [
                "Authorization": token
            ]
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(baseUrl + endpoint,
                           method: .get,
                           headers: headers
                )
                .validate()
                .responseDecodable(of: [MapPoint].self) { response in
                    handleResponse(response, continuation)
                }
            }
        }, searchPoints: { token, categories in
            let endpoint = "/points"
            
            let parameters: Parameters = [
                "categories": categories
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": token
            ]
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(baseUrl + endpoint,
                           method: .get,
                           parameters: parameters,
                           headers: headers
                )
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
    case .success(let value):
        continuation.resume(returning: value)
    case .failure(let error):
        if let data = response.data,
           let failResponse = try? JSONDecoder().decode(FailResponse.self, from: data) {
            continuation.resume(throwing: ErrorTypes.failedWithResponse(failResponse))
        } else {
            continuation.resume(throwing: error)
        }
    }
}

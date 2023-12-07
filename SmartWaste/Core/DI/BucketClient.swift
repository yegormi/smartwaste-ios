//
//  BucketClient.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import Foundation
import ComposableArchitecture
import Alamofire

// MARK: - API client interface

// Typically this interface would live in its own module, separate from the live implementation.
// This allows the feature to compile faster since it only depends on the interface.

@DependencyClient
struct BucketClient {
    var getCategories: @Sendable (_ token: String) async throws -> [BucketCategory]
    var getItems: @Sendable (_ token: String) async throws -> BucketList
    var scanPhoto: @Sendable (_ token: String, _ photo: Data) async throws -> BucketList
}

extension DependencyValues {
    var bucketClient: BucketClient {
        get { self[BucketClient.self] }
        set { self[BucketClient.self] = newValue }
    }
}

// MARK: - Live API implementation

extension BucketClient: DependencyKey, TestDependencyKey {
    static let liveValue = BucketClient(
        getCategories: { token in
            let endpoint = "/categories"
            
            let headers: HTTPHeaders = [
                "Authorization": "\(token)"
            ]
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(baseUrl + endpoint,
                           method: .get,
                           headers: headers
                )
                .validate()
                .responseDecodable(of: [BucketCategory].self) { response in
                    handleResponse(response, continuation)
                }
            }
        }, getItems: { token in
            let endpoint = "/items"
            
            let headers: HTTPHeaders = [
                "Authorization": "\(token)"
            ]
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(baseUrl + endpoint,
                           method: .get,
                           headers: headers
                )
                .validate()
                .responseDecodable(of: BucketList.self) { response in
                    handleResponse(response, continuation)
                }
            }
        }, scanPhoto: { token, photo in
            let endpoint = "/scan"
            
            let headers: HTTPHeaders = [
                "Authorization": "\(token)"
            ]
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(photo, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
                    },
                    to: baseUrl + endpoint,
                    method: .post,
                    headers: headers
                )
                .validate()
                .responseDecodable(of: BucketList.self) { response in
                    handleResponse(response, continuation)
                }
            }
        }
    )
}

// MARK: - Test Implementation

extension BucketClient {
    static let testValue = Self()
}

// MARK: - Constants

extension BucketClient {
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

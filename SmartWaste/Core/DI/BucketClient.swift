//
//  BucketClient.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import Alamofire
import ComposableArchitecture
import UIKit

// MARK: - API client interface

// Typically this interface would live in its own module, separate from the live implementation.
// This allows the feature to compile faster since it only depends on the interface.

@DependencyClient
struct BucketClient {
    var getCategories: @Sendable () async throws -> [BucketCategory]
    var getItems: @Sendable () async throws -> BucketOptions
    var scanPhoto: @Sendable (_ image: UIImage) async throws -> BucketOptions
    var dumpItems: @Sendable (_ bucket: [DumpEntity]) async throws -> ProgressResponse
}

extension DependencyValues {
    var bucketClient: BucketClient {
        get { self[BucketClient.self] }
        set { self[BucketClient.self] = newValue }
    }
}

// MARK: - Live API implementation

extension BucketClient: DependencyKey, TestDependencyKey {
    @Dependency(\.sessionClient) static var sessionClient
    static let session = sessionClient.current
    
    static let liveValue = BucketClient(
        getCategories: {
            let endpoint = "/categories"

            return try await withCheckedThrowingContinuation { continuation in
                session.request(baseUrl + endpoint,
                           method: .get)
                    .validate()
                    .responseDecodable(of: [BucketCategory].self) { response in
                        handleResponse(response, continuation)
                    }
            }
        }, getItems: {
            let endpoint = "/items"

            return try await withCheckedThrowingContinuation { continuation in
                session.request(baseUrl + endpoint,
                           method: .get)
                    .validate()
                    .responseDecodable(of: BucketOptions.self) { response in
                        handleResponse(response, continuation)
                    }
            }
        }, scanPhoto: {image in
            let endpoint = "/scan"
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw ErrorTypes.imageConversionError
            }

            return try await withCheckedThrowingContinuation { continuation in
                session.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(
                            imageData, withName: "Photo", fileName: "Photo.jpeg", mimeType: "image/jpeg"
                        )
                    },
                    to: baseUrl + endpoint,
                    method: .post
                )
                .validate()
                .uploadProgress(queue: .main, closure: { progress in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                .responseDecodable(of: BucketOptions.self) { response in
                    handleResponse(response, continuation)
                }
            }
        }, dumpItems: { bucket in
            let endpoint = "/dump"

            return try await withCheckedThrowingContinuation { continuation in
                session.request(Self.baseUrl + endpoint,
                           method: .post,
                           parameters: bucket,
                           encoder: JSONParameterEncoder.default)
                    .validate()
                    .responseDecodable(of: ProgressResponse.self) { response in
                        handleResponse(response, continuation)
                    }
            }
        }
    )
}

// MARK: - Test Implementation

extension BucketClient {
    static let testValue = BucketClient(
        getCategories: { 
            return [BucketCategory(id: 1, name: "Paper", slug: "paper", emoji: "📄")]
        },
        getItems: { 
            return BucketOptions(items: [])
        },
        scanPhoto: { _ in
            return BucketOptions(items: [])
        },
        dumpItems: { _ in
            return ProgressResponse(progresses: [])
        }
    )
}

// MARK: - Constants

extension BucketClient {
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

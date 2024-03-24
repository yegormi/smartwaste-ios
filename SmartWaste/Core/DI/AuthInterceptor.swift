//
//  AuthInterceptor.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.03.2024.
//

import Alamofire
import Foundation

struct AuthInterceptor: RequestInterceptor {
    private let tokenProvider: () -> String?

    init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }

    func adapt(_ urlRequest: URLRequest, for _: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var modifiedRequest = urlRequest

        if let token = tokenProvider() {
            modifiedRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }

        completion(.success(modifiedRequest))
    }

    func retry(_: Request, for _: Session, dueTo _: Error, completion: @escaping (RetryResult) -> Void) {
        // Handle retry logic if needed
        completion(.doNotRetry)
    }
}

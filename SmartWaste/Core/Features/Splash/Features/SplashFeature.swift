//
//  SplashFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 24.11.2023.
//
//

import Foundation
import ComposableArchitecture

@Reducer
struct SplashFeature: Reducer {
    @Dependency(\.keychainClient) var keychainClient

    struct State: Equatable {
        static let initialState = Self()
    }

    enum Action: Equatable {
        case appDidLaunch
        case auth
        case tabs
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .appDidLaunch:
                guard let _ = keychainClient.retrieveToken() else {
                    return .send(.auth)
                }
                return .send(.tabs)
            case .auth:
                return .none
            case .tabs:
                return .none
            }
        }
    }
}

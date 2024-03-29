//
//  ProfileCoordinator.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.11.2023.
//

import ComposableArchitecture
import Foundation
import TCACoordinators

@Reducer
struct ProfileCoordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
        var routes: [Route<ProfileScreen.State>]
        static let initialState = State(
            routes: [.root(.main(.init()))]
        )
    }

    enum Action: Equatable, IndexedRouterAction {
        case routeAction(Int, action: ProfileScreen.Action)
        case updateRoutes([Route<ProfileScreen.State>])
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, action in
            switch action {
            default:
                break
            }
            return .none
        }.forEachRoute {
            ProfileScreen()
        }
    }
}

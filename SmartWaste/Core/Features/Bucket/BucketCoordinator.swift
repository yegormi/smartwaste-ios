//
//  BucketCoordinator.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer
struct BucketCoordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
        var routes: [Route<BucketScreen.State>]
        static let initialState = State(
            routes: [.root(.main(.init()))]
        )
    }

    enum Action: Equatable, IndexedRouterAction {
        case routeAction(Int, action: BucketScreen.Action)
        case updateRoutes([Route<BucketScreen.State>])
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, action in
            switch action {
            default:
                break
            }
            return .none
        }.forEachRoute {
            BucketScreen()
        }
    }
}

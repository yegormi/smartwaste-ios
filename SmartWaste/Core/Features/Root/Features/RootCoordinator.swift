//
//  RootCoordinator.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 24.11.2023.
//

import ComposableArchitecture
import Foundation
import TCACoordinators

@Reducer
struct RootCoordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
        var routes: [Route<RootScreen.State>]
        static let initialState = State(
            routes: [.root(.splash(.init()))]
        )
    }

    enum Action: IndexedRouterAction {
        case routeAction(Int, action: RootScreen.Action)
        case updateRoutes([Route<RootScreen.State>])
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .routeAction(_, action: .splash(.auth)):
                state.routes.removeAll()
                state.routes.push(.auth(.init()))

            case .routeAction(_, action: .splash(.tabs)):
                state.routes.removeAll()
                state.routes.push(.tabs(.initState(from: .map)))

            case .routeAction(_, action: .auth(.authResponse(.success))):
                state.routes.removeAll()
                state.routes.push(.tabs(.initState(from: .map)))

            case .routeAction(_, action: .tabs(.alert(.presented(.expiredConfirmTapped)))):
                state.routes.removeAll()
                state.routes.push(.auth(.init()))

            case .routeAction(_, action: .tabs(.profile(.routeAction(_, action: .main(.onSignOutSuccess))))):
                state.routes.removeAll()
                state.routes.push(.auth(.init()))

            case .routeAction(_, action: .tabs(.bucket(.routeAction(_, action: .main(.wentToMap(let categories)))))):
                state.routes.removeAll()
                state.routes.push(.tabs(.initState(from: .map, with: categories)))

            default:
                break
            }
            return .none
        }.forEachRoute {
            RootScreen()
        }
    }
}

//
//  MapCoordinator.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer
struct MapCoordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
        var routes: [Route<MapScreen.State>]
        static let initialState = State(
            routes: [.root(.main(.init(points: [])))]
        )
    }
    
    enum Action: Equatable, IndexedRouterAction {
        case routeAction(Int, action: MapScreen.Action)
        case updateRoutes([Route<MapScreen.State>])
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            default:
                break
            }
            return .none
        }.forEachRoute {
            MapScreen()
        }
    }
}

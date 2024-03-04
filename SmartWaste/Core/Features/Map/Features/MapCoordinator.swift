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
            routes: [.root(.main(.init(points: [], categories: [])))]
        )

        static func initState(with categories: [String]) -> Self {
            State(
                routes: [.root(.main(.init(points: [], categories: categories)))]
            )
        }
    }

    enum Action: Equatable, IndexedRouterAction {
        case routeAction(Int, action: MapScreen.Action)
        case updateRoutes([Route<MapScreen.State>])
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
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

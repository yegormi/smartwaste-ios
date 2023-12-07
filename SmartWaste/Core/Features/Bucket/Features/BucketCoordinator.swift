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
struct BucketCoordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
        var routes: [Route<BucketScreen.State>]
        static let initialState = State(
            routes: [.root(.main(.init()), embedInNavigationView: true)]
        )
    }
    
    enum Action: Equatable, IndexedRouterAction {
        case routeAction(Int, action: BucketScreen.Action)
        case updateRoutes([Route<BucketScreen.State>])
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .routeAction(_, action: .main(.addItemTapped(let options))):
                state.routes.presentSheet(.addItem(.init(options: options)))
            case .routeAction(_, action: .addItem(.cancelButtonTapped)):
                state.routes.goBack()
            default:
                break
            }
            return .none
        }.forEachRoute {
            BucketScreen()
        }
    }
}

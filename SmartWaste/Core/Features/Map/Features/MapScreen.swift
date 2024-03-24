//
//  MapScreen.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MapScreen: Reducer {
    enum State: Equatable {
        case main(MapMain.State)
    }

    enum Action: Equatable {
        case main(MapMain.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: /State.main, action: /Action.main) {
            MapMain()
        }
    }
}

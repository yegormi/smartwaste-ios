//
//  CounterFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import ComposableArchitecture
import Foundation

@Reducer
struct CounterFeature: Reducer {
    struct State: Equatable {
        let min: Int
        let max: Int
        var value: Int = 0

        var minReached: Bool { value <= min }
        var maxReached: Bool { value >= max }
    }

    enum Action: Equatable {
        case decrement
        case increment
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrement:
                state.value = max(state.min, state.value - 1)
                return .none
            case .increment:
                state.value = min(state.max, state.value + 1)
                return .none
            }
        }
    }
}

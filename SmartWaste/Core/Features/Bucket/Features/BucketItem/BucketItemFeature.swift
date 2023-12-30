//
//  BucketItemFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import Foundation
import ComposableArchitecture

@Reducer
struct BucketItemFeature: Reducer {
    struct State: Equatable, Identifiable {
        let id: Int
        let name: String
        let categories: [BucketCategory]
        var counter: CounterFeature.State

        func toItem () -> BucketItem {
            return BucketItem(
                id: self.id,
                name: self.name,
                count: self.counter.value,
                categories: self.categories
            )
        }
    }

    enum Action: Equatable {
        case counter(CounterFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.counter, action: /Action.counter) {
            CounterFeature()
        }
    }
}

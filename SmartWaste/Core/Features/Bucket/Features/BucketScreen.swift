//
//  MapScreen.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BucketScreen: Reducer {
    enum State: Equatable {
        case main(BucketMain.State)
        case camera(BucketCamera.State)
    }
    
    enum Action: Equatable {
        case main(BucketMain.Action)
        case camera(BucketCamera.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: /State.main, action: /Action.main) {
            BucketMain()
        }
        Scope(state: /State.camera, action: /Action.camera) {
            BucketCamera()
        }
    }
}

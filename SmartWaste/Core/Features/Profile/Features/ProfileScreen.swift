//
//  ProfileScreen.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.11.2023.
//
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileScreen: Reducer {
    enum State: Equatable {
        case main(ProfileMain.State)
    }
    
    enum Action: Equatable {
        case main(ProfileMain.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: /State.main, action: /Action.main) {
            ProfileMain()
        }
    }
}

//
//  HomeMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.11.2023.
//

import SwiftUI
import ComposableArchitecture

struct ProfileMainView: View {
    let store: StoreOf<ProfileMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("Profile")
        }
        
    }
}

@Reducer
struct ProfileMain: Reducer {
    
    struct State: Equatable {
    }
        
    enum Action: Equatable {
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            }
        }
    }
}

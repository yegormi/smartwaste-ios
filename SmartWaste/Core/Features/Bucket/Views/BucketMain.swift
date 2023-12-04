//
//  MapMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct BucketMainView: View {
    let store: StoreOf<BucketMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("Bucket")
        }
        
    }
}

@Reducer
struct BucketMain: Reducer {
    
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

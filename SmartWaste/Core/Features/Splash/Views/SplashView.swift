//
//  SplashView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 24.11.2023.
//
//

import ComposableArchitecture
import SwiftUI

struct SplashView: View {
    let store: StoreOf<SplashFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("♻️ SmartWaste")
                .font(.system(size: 40))
                .bold()
                .transition(
                    .offset(y: -(Constants.screen.height))
                        .combined(with: .scale(scale: 0.5))
                        .combined(with: .opacity)
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        viewStore.send(.appDidLaunch, animation: .default)
                    }
                }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(
            store: Store(initialState: .initialState) {
                SplashFeature()
            }
        )
    }
}

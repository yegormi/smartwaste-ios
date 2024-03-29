//
//  RootCoordinatorView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.11.2023.
//
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct RootCoordinatorView: View {
    let store: StoreOf<RootCoordinator>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) { screen in
                switch screen {
                case .splash:
                    CaseLet(
                        /RootScreen.State.splash,
                        action: RootScreen.Action.splash,
                        then: SplashView.init
                    )
                case .auth:
                    CaseLet(
                        /RootScreen.State.auth,
                        action: RootScreen.Action.auth,
                        then: AuthView.init
                    )
                case .tabs:
                    CaseLet(
                        /RootScreen.State.tabs,
                        action: RootScreen.Action.tabs,
                        then: TabsView.init
                    )
                }
            }
        }
    }
}

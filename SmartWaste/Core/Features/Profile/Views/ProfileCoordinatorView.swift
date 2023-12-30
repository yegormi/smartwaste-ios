//
//  HomeCoordinatorView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.11.2023.
//
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct ProfileCoordinatorView: View {
    let store: StoreOf<ProfileCoordinator>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) { screen in
                switch screen {
                case .main:
                    CaseLet(
                        /ProfileScreen.State.main,
                         action: ProfileScreen.Action.main,
                         then: ProfileMainView.init
                    )
                }
            }
        }
    }
}

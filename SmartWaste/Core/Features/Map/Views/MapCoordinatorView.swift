//
//  MapCoordinatorView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct MapCoordinatorView: View {
    let store: StoreOf<MapCoordinator>
    
    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) { screen in
                switch screen {
                case .main:
                    CaseLet(
                        /MapScreen.State.main,
                         action: MapScreen.Action.main,
                         then: MapMainView.init
                    )
                }
            }
        }
    }
}

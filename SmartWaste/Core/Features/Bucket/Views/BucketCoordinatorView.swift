//
//  BucketCoordinatorView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct BucketCoordinatorView: View {
    let store: StoreOf<BucketCoordinator>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) { screen in
                switch screen {
                case .main:
                    CaseLet(
                        /BucketScreen.State.main,
                        action: BucketScreen.Action.main,
                        then: BucketMainView.init
                    )
                }
            }
        }
    }
}

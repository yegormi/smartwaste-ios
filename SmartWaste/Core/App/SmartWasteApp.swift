//
//  SmartWasteApp.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 24.10.2023.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import PartialSheet

@main
struct SmartWasteApp: App {         
    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(
                store: Store(initialState: .initialState) {
                    RootCoordinator()
                        ._printChanges()
                }
            )
            .attachPartialSheetToRoot()
        }
    }
}

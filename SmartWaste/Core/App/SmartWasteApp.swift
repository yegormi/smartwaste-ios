//
//  SmartWasteApp.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 24.10.2023.
//

import ComposableArchitecture
import SwiftUI

@main
struct SmartWasteApp: App {
    let store: StoreOf<RootCoordinator>
    let coreDataManager: CoreDataManager

    init() {
        store = Store(initialState: .initialState) {
            RootCoordinator()
                ._printChanges()
        }
        coreDataManager = CoreDataManager.shared
    }

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(
                store: self.store
            )
            .environment(\.managedObjectContext, coreDataManager.container.viewContext)
        }
    }
}

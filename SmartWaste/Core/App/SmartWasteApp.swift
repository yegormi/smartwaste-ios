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
    @Dependency(\.bucketListClient) var bucketListClient
    
    let store: StoreOf<RootCoordinator>
    let coreDataManager: CoreDataManager
    
    init() {
        self.store = Store(initialState: .initialState) {
            RootCoordinator()
                ._printChanges()
        }
        self.coreDataManager = CoreDataManager.shared
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

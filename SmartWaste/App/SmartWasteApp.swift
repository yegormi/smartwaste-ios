//
//  SmartWasteApp.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 14.11.2023.
//

import SwiftUI

@main
struct SmartWasteApp: App {
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(AuthViewModel())
        }
    }
}

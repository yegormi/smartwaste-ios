//
//  TabsTests.swift
//  SmartWasteTests
//
//  Created by Yegor Myropoltsev on 29.12.2023.
//

import XCTest
import ComposableArchitecture

@testable import SmartWaste

@MainActor
class TabsTests: XCTestCase {
    func testSwitchModes() async {
        let store = TestStore(initialState: TabsFeature.State(
            map: .initialState, profile: .initialState, bucket: .initialState, selectedTab: .map)) {
                TabsFeature()
        } withDependencies: {
            $0.keychainClient.retrieveToken = {
                AuthResponse(accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzAzODc1MzUzLCJleHAiOjE3MDM4Nzg5NTN9.AcXkuntCYTVWBTTMu0l89Sgl4SKgboR7PXJt2ush-gA")
            }
        }
        
        await store.send(.tabSelected(.profile)) {
            $0.selectedTab = .profile
        }
        
        await store.send(.tabSelected(.bucket)) {
            $0.selectedTab = .bucket
        }
        
        await store.send(.tabSelected(.bucket))
        await store.receive(.goBackToPrevious)
    }
}

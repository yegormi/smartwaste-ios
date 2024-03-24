//
//  AuthTests.swift
//  SmartWasteTests
//
//  Created by Yegor Myropoltsev on 29.12.2023.
//

import ComposableArchitecture
import XCTest

@testable import SmartWaste

@MainActor
class AuthTests: XCTestCase {
    func testSwitchModes() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        }

        await store.send(.emailChanged("deadbeef@gmail.com")) {
            $0.email = "deadbeef@gmail.com"
        }

        await store.send(.passwordChanged("12345")) {
            $0.password = "12345"
        }

        await store.send(.toggleButtonTapped) {
            $0.authType = .signUp
        }

        await store.send(.toggleButtonTapped) {
            $0.authType = .signIn
        }
    }
}

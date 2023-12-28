//
//  CounterTests.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 28.12.2023.
//

import XCTest
import ComposableArchitecture

@testable import SmartWaste

@MainActor
class CounterTests: XCTestCase {
    
    func testDecrement_ShouldDecrement() async {
        let store = TestStore(
            initialState: .init(min: 0, max: 10, value: 5)
        ) {
            CounterFeature()
        }
        
        await store.send(.decrement) {
            $0.value = 4
        }
    }
    
    func testIncrement_ShouldIncrement() async {
        let store = TestStore(
            initialState: .init(min: 0, max: 10, value: 5)
        ) {
            CounterFeature()
        }
        
        await store.send(.increment) {
            $0.value = 6
        }
    }
    
    func testDecrementAtMin_ShouldStayAtMin() async {
        let store = TestStore(
            initialState: .init(min: 0, max: 10, value: 0)
        ) {
            CounterFeature()
        }
        
        await store.send(.decrement)
        
        XCTAssertEqual(store.state.value, 0)
    }
    
    func testIncrementAtMax_ShouldStayAtMax() async {
        let store = TestStore(
            initialState: .init(min: 0, max: 10, value: 10)
        ) {
            CounterFeature()
        }
        
        await store.send(.increment)
        
        XCTAssertEqual(store.state.value, 10)
    }
}

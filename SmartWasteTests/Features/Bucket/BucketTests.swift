//
//  BucketTests.swift
//  SmartWasteTests
//
//  Created by Yegor Myropoltsev on 28.12.2023.
//

import XCTest
import ComposableArchitecture

@testable import SmartWaste

@MainActor
class BucketTests: XCTestCase {
    func testAddItem_ShouldAddSuccessfully() async {
        let store = TestStore(initialState: BucketMain.State()) {
            BucketMain()
        }
                
        await store.send(.addButtonTapped) {
            $0.addItem = AddFeature.State(
                counter: .init(min: 0, max: 10),
                title: "Add item",
                options: $0.bucketOptions,
                selection: $0.bucketOptions.first
            )
        }
        
        let defaultSelection = BucketOption(id: 1, name: "Glass bottle", categories: [])
        let item = BucketItem(id: 1, name: "Glass bottle", count: 1, categories: [])
        await store.send(.addItem(.presented(.selectionChanged(defaultSelection)))) {
            $0.addItem?.selection = defaultSelection
        }
        
        await store.send(.addItem(.presented(.counter(.increment)))) {
            $0.addItem?.counter.value = 1
        }
        
        await store.send(.addItem(.presented(.addButtonTapped)))
        await store.receive(.addItem(.presented(.addSucceeded(item))))
        await store.receive(.appendBucket(with: item)) {
            $0.bucketItems.append(item.toState())
        }
        await store.receive(.addItem(.dismiss)) {
            $0.addItem = nil
        }
    }
}


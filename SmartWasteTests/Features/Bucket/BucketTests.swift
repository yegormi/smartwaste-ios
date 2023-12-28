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
    func testAddItem_ShouldShowBottomSheet() async {
        let store = TestStore(initialState: BucketMain.State()) {
            BucketMain()
        }
        
        await store.send(.addButtonTapped) {
            $0.addItem = AddFeature.State(
                counter: .init(min: Constants.minCount, max: Constants.maxCount),
                title: "Add item",
                options: $0.bucketOptions,
                selection: $0.bucketOptions.first
            )
        }
    }
}

//
//  BucketMainFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BucketMain: Reducer {
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.bucketClient) var bucketClient
    
    struct State: Equatable {
        @PresentationState var addItem: AddFeature.State?
        
        var viewDidAppear: Bool = false
        var bucketItems: IdentifiedArrayOf<BucketItemFeature.State> = []
        
        var bucketOptions: [BucketItemOption] = []
    }
    
    enum Action: Equatable {
        case addItem(PresentationAction<AddFeature.Action>)
        case bucketItems(IdentifiedActionOf<BucketItemFeature>)
        
        case viewDidAppear
        
        /// Item Actions
        case getItems
        case getItemsSuccess([BucketItemOption])
        
        /// Bucket
        case appendBucket(with: BucketItem)
        
        /// Add item
        case addButtonTapped
        
        /// Recycle button
        case showRecyclePointsTapped
        case wentToMap(with: [String])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                state.viewDidAppear = true
                return .send(.getItems)
            case .getItems:
                return .run { send in
                    do {
                        let list = try await getItems()
                        let items = list.items
                        await send(.getItemsSuccess(items))
                    } catch {
                        print(error)
                    }
                }
            case let .getItemsSuccess(items):
                state.bucketOptions = items
                return .none
                
            case let .appendBucket(with: item):
                if state.bucketItems.firstIndex(where: { $0.id == item.id }) == nil {
                    state.bucketItems.append(.init(
                        id: item.id,
                        name: item.name,
                        categories: item.categories,
                        counter: .init(min: 0, max: 10, value: item.count)))
                }
                return .none
            case let .bucketItems(.element(id: id, action: .counter(.decrement))):
                /// Find the index of the corresponding item
                if let index = state.bucketItems.firstIndex(where: { $0.id == id }) {
                    /// Check if the counter value is zero
                    if state.bucketItems[index].counter.value == 0 {
                        /// Remove the item if the counter value is zero
                        state.bucketItems.remove(at: index)
                    }
                }
                return .none
                
            case .addButtonTapped:
                state.addItem = .init(
                    counter: .init(min: 0, max: 10),
                    title: "Add item",
                    options: state.bucketOptions,
                    selection: state.bucketOptions.first
                )
                return .none
            case .showRecyclePointsTapped:
                let categories = Array(Set(
                    state.bucketItems.flatMap { $0.categories.map { $0.slug } }
                ))
                return .send(.wentToMap(with: categories))
                
            case .wentToMap:
                return .none
                
            case let .addItem(.presented(.onAddSuccess(item))):
                return .send(.appendBucket(with: item))
            case .addItem:
                return .none
            case .bucketItems:
                return .none
            }
        }
        .ifLet(\.$addItem, action: \.addItem) {
            AddFeature()
        }
        .forEach(\.bucketItems, action: \.bucketItems) {
            BucketItemFeature()
        }
    }
    
    private func getItems() async throws -> BucketList {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.getItems(token: token)
    }
}

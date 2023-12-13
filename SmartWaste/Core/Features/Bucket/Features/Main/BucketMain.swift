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
        
        var viewDidAppear = false
        var isErrorPresented = false
        
        var bucketItems: IdentifiedArrayOf<BucketItemFeature.State> = []
        
        var bucketOptions: [BucketItemOption] = []
    }
    
    enum Action: Equatable {
        case addItem(PresentationAction<AddFeature.Action>)
        case bucketItems(IdentifiedActionOf<BucketItemFeature>)
        
        case viewDidAppear
        case errorPresented
        
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
            case .errorPresented:
                state.isErrorPresented.toggle()
                return .none
                
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
                guard state.bucketItems[id: item.id] == nil else {
                    /// If the item already exists
                    return .send(.errorPresented)
                }
                let itemState = item.toState()
                state.bucketItems.append(itemState)
                return .none
                
            case let .bucketItems(.element(id: id, action: .counter(.decrement))):
                guard state.bucketItems[id: id]?.counter.value == 0 else {
                    return .none
                }
                state.bucketItems.remove(id: id)
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

            case let .addItem(.presented(.onAddSuccess(item))):
                return .send(.appendBucket(with: item))
                
            case .wentToMap:
                return .none
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

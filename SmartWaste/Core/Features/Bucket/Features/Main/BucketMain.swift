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
        
        var viewDidAppear:    Bool = false
        
        var bucket:     [BucketItem] = []
        var categories: [String] = []
        
        var bucketOptions: [BucketItemOption] = []
    }
    
    enum Action: Equatable {
        case addItem(PresentationAction<AddFeature.Action>)
        
        case viewDidAppear
        
        /// Item Actions
        case getItems
        case getItemsSuccess([BucketItemOption])
        
        /// Bucket
        case setBucket(with: BucketItem)
        case updateItemCount(itemID: Int, newCount: Int)
        case deleteItem(itemID: Int)
        
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
            case .getItemsSuccess(let items):
                state.bucketOptions = items
                return .none
                
            case .setBucket(with: let item):
                if state.bucket.firstIndex(where: { $0.id == item.id }) == nil {
                    state.bucket.append(item)
                }
                return .none
            case .updateItemCount(let itemID, let newCount):
                if let index = state.bucket.firstIndex(where: { $0.id == itemID }) {
                    state.bucket[index].updateCount(newCount)
                }
                if newCount == 0 {
                    return .send(.deleteItem(itemID: itemID))
                }
                return .none
            case .deleteItem(let itemID):
                state.bucket.removeAll { $0.id == itemID }
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
                state.categories = Array(Set(state.bucket.flatMap { $0.categories?.map { $0.slug } ?? [] }))
                return .send(.wentToMap(with: state.categories))
            case .wentToMap:
                return .none
                
            case .addItem(.presented(.onAddSuccess(let item))):
                state.bucket.append(item)
                return .none
            case .addItem:
                return .none
            }
        }
        .ifLet(\.$addItem, action: \.addItem) {
            AddFeature()
        }
    }
    
    private func getItems() async throws -> BucketList {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.getItems(token: token)
    }
}

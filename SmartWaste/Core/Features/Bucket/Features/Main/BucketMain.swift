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
    @Dependency(\.keychainClient)   var keychainClient
    @Dependency(\.bucketListClient) var bucketListClient
    @Dependency(\.bucketClient)     var bucketClient
    
    struct State: Equatable {
        @PresentationState var addItem: AddFeature.State?
        
        var viewDidAppear = false
        var isError = false
        var errorToast: String = ""
        
        var bucketItems: IdentifiedArrayOf<BucketItemFeature.State> = []
        var bucketOptions: [BucketOption] = []
    }
    
    enum Action: Equatable {
        case addItem(PresentationAction<AddFeature.Action>)
        case bucketItems(IdentifiedActionOf<BucketItemFeature>)
        
        case viewDidAppear
        case onFetched([BucketItem])
        case errorToggled
        case showErrorToast(String)
        
        /// Item Actions
        case getItems
        case getItemsSuccess([BucketOption])
        
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
                return .run { send in
                    do {
                        let bucketItems = try await bucketListClient.fetchBucketItems()
                        await send(.onFetched(bucketItems))
                    } catch {
                        print(error)
                    }
                }
            case .onFetched(let items):
                state.bucketItems = IdentifiedArrayOf(uniqueElements: items.map { $0.toState() })
                whereIsMyDB()
                return .send(.getItems)
            case .errorToggled:
                state.isError.toggle()
                return .none
            case .showErrorToast(let text):
                state.errorToast = text
                return .send(.errorToggled)
                
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
                    return .send(.showErrorToast("Item already exists"))
                }
                let itemState = item.toState()
                state.bucketItems.append(itemState)
                return .none
                
            case let .bucketItems(.element(id: id, action: .counter(.decrement))):
                guard state.bucketItems[id: id]?.counter.value == 0 else {
                    return .none
                }
                state.bucketItems.remove(id: id)
                return .run { send in
                    do {
//                        try await bucketListClient.deleteBucketItem(by: id)
                    } catch {
                        print(error)
                    }
                }
                
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
                
            case let .addItem(.presented(.addSucceeded(item))):
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
    
    private func getItems() async throws -> BucketOptions {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.getItems(token: token)
    }
}

func whereIsMyDB() {
    let path = FileManager
        .default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .last?
        .absoluteString
        .replacingOccurrences(of: "file://", with: "")
        .removingPercentEncoding
    
    print("🟦 \(path ?? "Not found")")
}

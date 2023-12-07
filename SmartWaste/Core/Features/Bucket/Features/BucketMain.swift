//
//  BucketMainFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import UIKit
import ComposableArchitecture

@Reducer
struct BucketMain: Reducer {
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.bucketClient) var bucketClient
    
    struct State: Equatable {
        var viewDidAppear = false
        
        var bucket: [BucketItem] = []
        
        var bucketOptions: [BucketItemOption] = []
        var optionSelected: BucketItemOption? = nil
        
        var capturedImage: UIImage?
    }
    
    enum Action: Equatable {
        case viewDidAppear
        
        case getItems
        case onGetItemsSuccess([BucketItemOption])
        case setInitialItem

        case selectionChanged(BucketItemOption)
        
        case addItemTapped([BucketItemOption])
        case showRecyclePointsTapped
        
        case onScanButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .viewDidAppear:
                state.viewDidAppear = true
                return .send(.getItems)
            case .getItems:
                return .run { send in
                    do {
                        let list = try await getItems()
                        let items = list.items
                        await send(.onGetItemsSuccess(items))
                    } catch {
                        print(error)
                    }
                }
            case .onGetItemsSuccess(let items):
                state.bucketOptions = items
                return .send(.setInitialItem)
            case .setInitialItem:
                state.optionSelected = state.bucketOptions.first
                return .none
                
            case .addItemTapped:
                return .none
            case .showRecyclePointsTapped:
                return .none
                
            case .selectionChanged(let option):
                state.optionSelected = option
                return .none
            case .onScanButtonTapped:
                return .none
            }
        }
    }
    
    private func getItems() async throws -> BucketList {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.getItems(token: token)
    }
    
    private func scanPhoto() async throws -> BucketList {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.getItems(token: token)
    }
}

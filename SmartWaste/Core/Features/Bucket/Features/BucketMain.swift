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
    @Dependency(\.authClient) var authClient
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.bucketClient) var bucketClient
    
    struct State: Equatable {
        var isSheetPresented = false
        var viewDidAppear = false
        var items: [BucketItem] = []
        var types: [String] = []
        var itemSelected: String = ""
    }
    
    enum Action: Equatable {
        case viewDidAppear
        
        case getItems
        case onGetItemsSuccess([BucketItem])
        
        case filterTypes
        case setInitialItem([String])
        
        case onScanButtonTapped
        
        case selectionChanged(String)
        
        case sheetToggled
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .sheetToggled:
                state.isSheetPresented.toggle()
                return .none
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
                state.items = items
                return .send(.filterTypes)
            case .filterTypes:
                state.types = state.items.map { $0.name }
                return .send(.setInitialItem(state.types))
            case .setInitialItem(let array):
                state.itemSelected = array.first ?? "Selection is nil"
                return .none
                
            case .onScanButtonTapped:
                return .none
                
            case .selectionChanged(let option):
                state.itemSelected = option
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

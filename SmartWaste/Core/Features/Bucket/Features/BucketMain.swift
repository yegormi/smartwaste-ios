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
        
        var progress: ProgressResponse? = nil
        
        var capturedImage: UIImage?
        
        var isSheetPresented = false
        var isToastPresented = false
    }
    
    enum Action: Equatable {
        case viewDidAppear
        case toastPresented
        
        case getItems
        case onGetItemsSuccess([BucketItemOption])
        case setInitialItem
        
        case selectionChanged(BucketItemOption)
        
        case sheetToggled(Bool)
        
        case showRecyclePointsTapped
        case dumpItems
        case onDumpItemsSuccess(ProgressResponse)
        
        case onScanButtonTapped
        
        case setBucket(with: BucketItem)
        case updateItemCount(itemID: Int, newCount: Int)
        case deleteItem(itemID: Int)
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .viewDidAppear:
                state.viewDidAppear = true
                return .send(.getItems)
            case .toastPresented:
                state.isToastPresented.toggle()
                return .none
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
                
            case .sheetToggled(let toggle):
                state.isSheetPresented = toggle
                return .none
                
            case .showRecyclePointsTapped:
                return .send(.dumpItems)
            case .dumpItems:
                let bucketDump = BucketDump(bucketItems: state.bucket)
                return .run { send in
                    do {
                        let progress = try await dumpItems(bucket: bucketDump.items)
                        await send(.onDumpItemsSuccess(progress))
                    } catch {
                        print(error)
                    }
                }
            case .onDumpItemsSuccess(let progress):
                state.progress = progress
                return .none
            case .selectionChanged(let option):
                state.optionSelected = option
                return .none
            case .onScanButtonTapped:
                return .none
                
            case .setBucket(with: let item):
                if let _ = state.bucket.firstIndex(where: { $0.id == item.id }) {
                    return .none
                } else {
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
    
    private func dumpItems(bucket: [DumpEntity]) async throws -> ProgressResponse {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.dumpItems(token: token, bucket: bucket)
    }
}

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
        var categories: [String] = []
        
        var bucketOptions: [BucketItemOption] = []
        var optionSelected: BucketItemOption? = nil
        
        var progress: ProgressResponse? = nil
        
        var capturedImage: UIImage?
        
        var isSheetPresented = false
        var isErrorToastPresented = false
        var isLoadingToastPresented = false
        var isCameraPresented = false
                
        var photoResponse: BucketList? = nil
    }
    
    enum Action: Equatable {
        case viewDidAppear
        
        /// Item Actions
        case getItems
        case onGetItemsSuccess([BucketItemOption])
        case setInitialItem
        
        case selectionChanged(BucketItemOption)
        
        case setBucket(with: BucketItem)
        case updateItemCount(itemID: Int, newCount: Int)
        case deleteItem(itemID: Int)
        
        /// UI Actions
        case errorToastToggled
        case loadingToastToggled
        
        case sheetToggled(Bool)
        case showRecyclePointsTapped
        
        /// Dump Actions
        case dumpItems
        case onDumpItemsSuccess(ProgressResponse)
        case clearBucket
        case setCategoriesFromBucket
        case wentToMap(with: [String])
        
        /// Camera Actions
        case onScanButtonTapped
        case cameraPresented
        case usePhotoTapped
        case imageCaptured(UIImage)
        
        case scanPhoto
        case onScanPhotoSuccess(BucketList)
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
                // MARK: - View Lifecycle
            case .viewDidAppear:
                state.viewDidAppear = true
                return .send(.getItems)
                
                // MARK: - Toast and Loading
            case .errorToastToggled:
                state.isErrorToastPresented.toggle()
                return .none
            case .loadingToastToggled:
                state.isLoadingToastPresented.toggle()
                return .none
                
                // MARK: - Item Actions
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
            case .selectionChanged(let option):
                state.optionSelected = option
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
                
                // MARK: - Sheet and UI Actions
            case .sheetToggled(let toggle):
                state.isSheetPresented = toggle
                return .none
            case .showRecyclePointsTapped:
                return .send(.setCategoriesFromBucket)
            case .setCategoriesFromBucket:
                state.categories = Array(Set(state.bucket.flatMap { $0.categories?.map { $0.slug } ?? [] }))
                return .send(.wentToMap(with: state.categories))
            case .wentToMap:
                return .none
            
                // MARK: Dump Action
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
                return .send(.clearBucket)
            case .clearBucket:
                state.bucket = []
                return .none
                
                // MARK: - Camera Actions
            case .onScanButtonTapped:
                return .send(.cameraPresented)
            case .cameraPresented:
                state.isCameraPresented.toggle()
                return .none
            case .usePhotoTapped:
                state.isLoadingToastPresented.toggle()
                return .send(.scanPhoto)
            case .scanPhoto:
                return .run { [image = state.capturedImage] send in
                    do {
                        let item = try await scanPhoto(image ?? UIImage.checkmark)
                        await send(.onScanPhotoSuccess(item))
                    } catch ErrorResponse.imageConversionError {
                        print("Image could not be converted properly")
                    } catch {
                        print(error)
                    }
                }
            case .onScanPhotoSuccess(let result):
                state.photoResponse = result
                
                guard let firstItem = result.items.first else {
                    state.isLoadingToastPresented.toggle()
                    return .send(.errorToastToggled)
                }
                
                // Update the selection based on the matching item ID
                if let matchingOption = state.bucketOptions.first(where: { $0.id == firstItem.id }) {
                    state.optionSelected = matchingOption
                    return .send(.loadingToastToggled)
                }
    
                return .none
                
            case .imageCaptured(let image):
                state.capturedImage = image
                return .none
            }
        }
    }
    
    private func getItems() async throws -> BucketList {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.getItems(token: token)
    }
    
    private func scanPhoto(_ image: UIImage) async throws -> BucketList {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.scanPhoto(token: token, image: image)
    }
    
    private func dumpItems(bucket: [DumpEntity]) async throws -> ProgressResponse {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.dumpItems(token: token, bucket: bucket)
    }
}

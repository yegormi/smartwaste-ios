//
//  AddFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import UIKit
import ComposableArchitecture

@Reducer
struct AddFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        var counter: CounterFeature.State
        
        var title: String
        var options: [BucketItemOption]
        var selection: BucketItemOption?
        var emptySelection = BucketItemOption(id: 1, name: "Material", categories: [])
        
        var capturedImage: UIImage? = nil
        var imageResponse: BucketList? = nil
        var countError: String? = nil
        
        func createBucketItem() -> BucketItem {
            guard let selectedOption = selection else {
                fatalError("Selection should not be nil.")
            }
            
            return BucketItem(
                id: selectedOption.id,
                name: selectedOption.name,
                count: counter.value,
                categories: selectedOption.categories
            )
        }
    }
    
    enum Action: Equatable {
        case counter(CounterFeature.Action)
        
        case selectionChanged(BucketItemOption)
        
        case scanButtonTapped
        case scanPhoto
        case scanPhotoSuccess(BucketList)
        
        case addButtonTapped
        case onAddSuccess(BucketItem)
        case cancelButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.counter, action: /Action.counter) {
            CounterFeature()
        }
        Reduce { state, action in
            switch action {
            case .counter:
                return .none
                
            case .selectionChanged(let option):
                state.selection = option
                return .none
                
            case .scanButtonTapped:
                return .none
            case .scanPhoto:
                return .none
            case .scanPhotoSuccess(_):
                return .none
                
            case .addButtonTapped:
                guard state.counter.value > 0 else {
                    state.countError = "You must add one or more items"
                    return .none
                }
                
                state.countError = nil
                let bucketItem = state.createBucketItem()
                
                return .send(.onAddSuccess(bucketItem))
            case .onAddSuccess:
                return .run { _ in
                    await dismiss()
                }
                
            case .cancelButtonTapped:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}
//
//  AddItemFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.12.2023.
//
//

import UIKit
import ComposableArchitecture

struct AddItemFeature: Reducer {
    struct State: Equatable {
        var options: [BucketItemOption] = []
        var selection: BucketItemOption? = nil
        var capturedImage: UIImage?

        var isPickerActive: Bool = false
        var count: Int = 0
    }
    
    enum Action: Equatable {
        case viewDidAppear
        case setInitialOption
        
        case pickerChanged(BucketItemOption)
        case onScanButtonTapped
        
        case onIncrement
        case onDecrement
        
        case addButtonTapped
        case cancelButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .viewDidAppear:
                return .send(.setInitialOption)
            case .setInitialOption:
                state.selection = state.options.first
                return .none
                
            case .pickerChanged(let option):
                state.selection = option
                return .none
            case .onScanButtonTapped:
                return .none
                
            case .onDecrement:
                state.count -= 1
                return .none
            case .onIncrement:
                state.count += 1
                return .none
                
            case .addButtonTapped:
                return .none
            case .cancelButtonTapped:
                return .none
            }
            
        }
    }
}

//
//  CameraFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 13.12.2023.
//
//

import UIKit
import ComposableArchitecture

@Reducer
struct CameraFeature: Reducer {
    struct State: Equatable {
    }
    
    enum Action: Equatable {
        case usePhotoTapped(with: UIImage)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .usePhotoTapped:
                return .none
            }
        }
    }
}

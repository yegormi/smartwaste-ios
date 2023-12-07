//
//  BucketCamera.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct BucketCameraView: View {
    let store: StoreOf<BucketCamera>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            CameraView(capturedImage: viewStore.binding(
                get: \.capturedImage,
                send: BucketCamera.Action.imageCaptured
            ), isCameraShown: viewStore.binding(
                get: \.isCameraShown,
                send: BucketCamera.Action.cameraStateChanged
            ))
        }
        
    }
}

@Reducer
struct BucketCamera: Reducer {
    
    struct State: Equatable {
        var capturedImage: UIImage?
        var isCameraShown: Bool = false
    }
    
    enum Action: Equatable {
        case imageCaptured
        case cameraStateChanged
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .imageCaptured:
                return .none
            case .cameraStateChanged:
                return .none
            }
        }
    }
}

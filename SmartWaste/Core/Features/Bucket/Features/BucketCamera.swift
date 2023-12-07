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
                send: { .imageCaptured($0 ?? UIImage.checkmark) }
            ))
            .onDisappear {
                viewStore.send(.usePhotoButtonTapped(viewStore.capturedImage ?? UIImage.checkmark))
            }
        }
        
    }
}

@Reducer
struct BucketCamera: Reducer {
    
    struct State: Equatable {
        var capturedImage: UIImage?
    }
    
    enum Action: Equatable {
        case imageCaptured(UIImage)
        case usePhotoButtonTapped(UIImage)
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .imageCaptured(let image):
                state.capturedImage = image
                return .none
            case .usePhotoButtonTapped:
                return .none
            }
        }
    }
}

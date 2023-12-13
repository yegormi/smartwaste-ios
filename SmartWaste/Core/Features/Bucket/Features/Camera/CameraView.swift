//
//  CameraView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 13.12.2023.
//
//

import SwiftUI
import ComposableArchitecture

struct CameraView: View {
    let store: StoreOf<CameraFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            CameraRepresentable() { image in 
                viewStore.send(.usePhotoTapped(with: image))
            }
        }
    }
}

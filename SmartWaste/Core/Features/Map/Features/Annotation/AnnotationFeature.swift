//
//  AnnotationFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import Foundation
import ComposableArchitecture

@Reducer
struct AnnotationFeature: Reducer {
    struct State: Equatable {
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        
        var annotation: AnnotationMark
        var isAllowedToDump: Bool
    }
    
    enum Action: Equatable {
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        
        case goButtonTapped
        case dumpBucketTapped
        
        enum ConfirmationDialog: Equatable {
            case appleMapsTapped
            case googleMapsTapped
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .goButtonTapped:
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("Confirmation dialog")
                } actions: {
                    ButtonState(action: .appleMapsTapped) {
                        TextState("Apple Maps")
                    }
                    ButtonState(action: .googleMapsTapped) {
                        TextState("Google Maps")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }

                } message: {
                    TextState("Choose application")
                }
                return .none
            case .confirmationDialog(.presented(.appleMapsTapped)):
                openRoute(with: state.annotation, in: .appleMaps)
                return .none
            case .confirmationDialog(.presented(.googleMapsTapped)):
                openRoute(with: state.annotation, in: .googleMaps)
                return .none
                
            case .dumpBucketTapped:
                return .none
                
            case .confirmationDialog:
                return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
        
    }
    
    private func openRoute(with anotation: AnnotationMark, in application: MapLink) {
        application.open(with: anotation.coordinate)
    }
}

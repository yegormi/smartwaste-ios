//
//  AddFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import ComposableArchitecture
import UIKit

@Reducer
struct AddFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.bucketClient) var bucketClient
    @Dependency(\.keychainClient) var keychainClient

    struct State: Equatable {
        var counter: CounterFeature.State
        @PresentationState var camera: CameraFeature.State?

        var title: String
        var options: [BucketOption]
        var selection: BucketOption?
        var emptySelection = BucketOption(id: 1, name: "Material", categories: [])

        var capturedImage: UIImage?
        var imageResponse: BucketOptions?
        var errorText: String?
        var errorToast: String = ""

        var isLoading = false
        var isError = false

        func createBucketItem() throws -> BucketItem {
            guard let selectedOption = selection else {
                throw ErrorTypes.selectionEmpty
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
        case camera(PresentationAction<CameraFeature.Action>)

        case selectionChanged(BucketOption)
        case showError(String)
        case showErrorToast(String)

        case scanButtonTapped
        case scanPhoto
        case scanPhotoSuccess(BucketOptions)

        case loadingPresented(Bool)
        case errorToastToggled

        case addButtonTapped
        case addSucceeded(BucketItem)
        case cancelButtonTapped
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.counter, action: /Action.counter) {
            CounterFeature()
        }
        Reduce { state, action in
            switch action {
            case let .selectionChanged(option):
                state.selection = option
                return .none

            case .scanButtonTapped:
                state.camera = .init()
                return .none
            case let .camera(.presented(.usePhotoTapped(with: image))):
                state.capturedImage = image
                // Present loading indicator
                state.isLoading.toggle()
                return .send(.scanPhoto)

            case .scanPhoto:
                return .run { [image = state.capturedImage] send in
                    do {
                        let item = try await scanPhoto(image ?? UIImage.checkmark)
                        await send(.scanPhotoSuccess(item))
                    } catch ErrorTypes.imageConversionError {
                        print("Image could not be converted properly")
                    } catch {
                        print(error)
                    }
                }
            case let .scanPhotoSuccess(result):
                state.imageResponse = result

                guard let matched = result.items.first else {
                    /// Hide loading indicator
                    state.isLoading.toggle()
                    /// Present error toast image not recognized
                    return .send(.errorToastToggled)
                }

                // Update the selection based on the matching item ID
                if let matchingOption = state.options.first(where: { $0.id == matched.id }) {
                    state.selection = matchingOption
                }

                /// Hide loading indicator
                state.isLoading.toggle()
                return .none

            case let .loadingPresented(isOn):
                state.isLoading = isOn
                return .none
            case .errorToastToggled:
                state.isError.toggle()
                return .none
            case let .showErrorToast(text):
                state.errorToast = text
                return .send(.errorToastToggled)

            case .counter(.increment):
                state.errorText = nil
                return .none
            case let .showError(text):
                state.errorText = text
                return .none

            case .addButtonTapped:
                guard state.counter.value > 0 else {
                    return .send(.showError("You must add one or more items"))
                }
                return .run { [state] send in
                    do {
                        let bucketItem = try state.createBucketItem()
                        await send(.addSucceeded(bucketItem))
                    } catch ErrorTypes.selectionEmpty {
                        await send(.showErrorToast("Selection is empty!"))
                    } catch {
                        print(error)
                    }
                }

            case .addSucceeded:
                state.errorText = nil
                return .run { _ in
                    await dismiss()
                }

            case .cancelButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .counter:
                return .none
            case .camera:
                return .none
            }
        }
        .ifLet(\.$camera, action: \.camera) {
            CameraFeature()
        }
    }

    private func scanPhoto(_ image: UIImage) async throws -> BucketOptions {
        return try await bucketClient.scanPhoto(image: image)
    }
}

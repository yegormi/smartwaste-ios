//
//  AnnotationFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import ComposableArchitecture
import CoreLocation
import Foundation

@Reducer
struct AnnotationFeature: Reducer {
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.bucketClient) var bucketClient
    @Dependency(\.bucketDB) var bucketDB
    @Dependency(\.dismiss) var dismiss

    struct State: Equatable {
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?

        var annotation: AnnotationMark

        var isDumpAllowed: Bool = false
        var bucket: [BucketItem]?
        var progress: ProgressResponse?
    }

    enum Action: Equatable {
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case viewDidAppear

        case goButtonTapped

        case dumpBucketTapped

        case checkDistance
        case onCheckSuccess(Bool)
        case getBucket
        case onGetBucketSuccess([BucketItem])

        case dumpItems
        case onDumpItemsSuccess(ProgressResponse)
        case clearBucket

        enum ConfirmationDialog: Equatable {
            case appleMapsTapped
            case googleMapsTapped
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return .send(.checkDistance)
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
                    TextState("Choose map application")
                }
                return .none
            case .confirmationDialog(.presented(.appleMapsTapped)):
                openRoute(with: state.annotation, in: .appleMaps)
                return .none
            case .confirmationDialog(.presented(.googleMapsTapped)):
                openRoute(with: state.annotation, in: .googleMaps)
                return .none

            case .dumpBucketTapped:
                return .send(.dumpItems)

            case .confirmationDialog:
                return .none

                // MARK: Dump Action

            case .checkDistance:
                if let userLocation = getUserLocation() {
                    let isWithinRadius = isWithin(
                        radius: 1000,
                        userLocation: userLocation,
                        pointLocation: state.annotation.coordinate
                    )
                    return .send(.onCheckSuccess(isWithinRadius))
                }
                return .none
            case let .onCheckSuccess(isWithinRadius):
                if isWithinRadius {
                    state.isDumpAllowed = true
                    return .send(.getBucket)
                } else {
                    state.isDumpAllowed = false
                }
                return .none
            case .getBucket:
                return .run { send in
                    do {
                        let items = try await bucketDB.fetchBucketItems()
                        await send(.onGetBucketSuccess(items))
                    } catch {
                        print(error)
                    }
                }
            case let .onGetBucketSuccess(items):
                state.bucket = items
                return .none
            case .dumpItems:
                let bucketDump = BucketDump(bucket: state.bucket!)
                return .run { send in
                    do {
                        let progress = try await dumpItems(bucket: bucketDump.items)
                        await send(.onDumpItemsSuccess(progress))
                    } catch {
                        print(error)
                    }
                }
            case let .onDumpItemsSuccess(progress):
                state.progress = progress
                return .send(.clearBucket)
            case .clearBucket:
                /// Clear bucket in database
                return .run { _ in
                    try await bucketDB.deleteAllBucketItems()
                    await dismiss()
                }
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}

extension AnnotationFeature {
    private func openRoute(with anotation: AnnotationMark, in application: MapLink) {
        application.open(with: anotation.coordinate)
    }

    private func dumpItems(bucket: [DumpEntity]) async throws -> ProgressResponse {
        return try await bucketClient.dumpItems(bucket: bucket)
    }

    private func getUserLocation() -> CLLocationCoordinate2D? {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        if let location = locationManager.location?.coordinate {
            return location
        }

        return nil
    }

    private func isWithin(radius: Double, userLocation: CLLocationCoordinate2D, pointLocation: CLLocationCoordinate2D) -> Bool {
        let userLocationCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let pointLocationCLLocation = CLLocation(latitude: pointLocation.latitude, longitude: pointLocation.longitude)

        // Distance in meters
        let distance = userLocationCLLocation.distance(from: pointLocationCLLocation)

        return distance <= radius
    }
}

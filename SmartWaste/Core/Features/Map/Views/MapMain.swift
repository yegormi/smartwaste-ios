//
//  MapMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import ComposableArchitecture
import MapKit
import CoreLocation
import BottomSheet

struct MapMainView: View {
    let store: StoreOf<MapMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            MapViewRepresentable(mapPoints: viewStore.points) { annotation in
                viewStore.send(.onAnnotationTapped(annotation), animation: .default)
            }
            .onAppear {
                if !viewStore.viewDidAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
            .bottomSheet(
                isPresented: viewStore.binding(
                    get: \.isSheetPresented,
                    send: MapMain.Action.sheetToggled
                ),
                prefersGrabberVisible: true
            ) {
                AnnotationDetailsVIew(
                    annotation: viewStore.annotation ?? viewStore.emptyAnnotation,
                    onGoButtonTapped: { viewStore.send(.goButtonTapped) },
                    onDumpBucketTapped: { },
                    isAllowedToDump: viewStore.isDumpAllowed
                )
                .onAppear {
                    viewStore.send(.sheetDidAppear)
                }
                .confirmationDialog("", isPresented: viewStore.binding(
                    get: \.isActionPresented,
                    send: MapMain.Action.actionPresented
                )) {
                    Button("Apple Maps") {
                        if let annotation = viewStore.annotation {
                            viewStore.send(.openRoute(with: annotation, in: .appleMaps))
                        }
                    }
                    Button("Google Maps") {
                        if let annotation = viewStore.annotation {
                            viewStore.send(.openRoute(with: annotation, in: .googleMaps))
                        }
                    }
                }
                .padding(30)
            }
        }
        
    }
}

@Reducer
struct MapMain: Reducer {
    @Dependency(\.mapClient)      var mapClient
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.bucketClient)   var bucketClient
    
    
    struct State: Equatable {
        var points: [MapPoint]
        var categories: [String]
        var viewDidAppear = false
        var annotation: AnnotationMark? = nil
        var emptyAnnotation = AnnotationMark(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            name: "",
            address: "",
            emoji: []
        )
        var isSheetPresented = false
        var isActionPresented = false
        var isDumpAllowed = false
    }
    
    enum Action: Equatable {
        case viewDidAppear
        
        case getPoints
        case searchPoints([String])
        case onGetPointsSuccess([MapPoint])
        
        case onAnnotationTapped(AnnotationMark)
        case sheetToggled
        
        case goButtonTapped
        case actionPresented
        case openRoute(with: AnnotationMark, in: MapLink)
        
        case sheetDidAppear
        case checkDistance
        case onCheckSuccess(Bool)
        
        //        case dumpItems
        //        case onDumpItemsSuccess(ProgressResponse)
        //        case clearBucket
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .viewDidAppear:
                state.viewDidAppear = true
                if state.categories.isEmpty {
                    return .send(.getPoints)
                }
                return .send(.searchPoints(state.categories))
            case .getPoints:
                return .run { send in
                    do {
                        let points = try await getPoints()
                        await send(.onGetPointsSuccess(points), animation: .default)
                    } catch {
                        print(error)
                    }
                }
            case .searchPoints(let categories):
                return .run { send in
                    do {
                        let points = try await searchPoints(with: categories)
                        await send(.onGetPointsSuccess(points), animation: .default)
                    } catch {
                        print(error)
                    }
                }
            case .onGetPointsSuccess(let points):
                state.points = points
                return .none
            case .onAnnotationTapped(let annotation):
                state.annotation = annotation
                return .send(.sheetToggled)
            case .sheetToggled:
                state.isSheetPresented.toggle()
                return .none
                
            case .goButtonTapped:
                return .send(.actionPresented)
            case .actionPresented:
                state.isActionPresented.toggle()
                return .none
            case .openRoute(let annotation, let app):
                openRoute(with: annotation, in: app)
                return .none
            case .sheetDidAppear:
                return .send(.checkDistance)
            case .checkDistance:
                if let userLocation = getUserLocation(), let pointLocation = state.annotation?.coordinate {
                    let isWithinRadius = isWithin(radius: 1000, userLocation: userLocation, pointLocation: pointLocation)
                    return .send(.onCheckSuccess(isWithinRadius))
                }
                return .none
            case .onCheckSuccess(let isWithinRadius):
                if isWithinRadius {
                    state.isDumpAllowed = true
                } else {
                    state.isDumpAllowed = false
                }
                return .none
                
                //                // MARK: Dump Action
                //            case .dumpItems:
                //                let bucketDump = BucketDump(bucketItems: state.bucket)
                //                return .run { send in
                //                    do {
                //                        let progress = try await dumpItems(bucket: bucketDump.items)
                //                        await send(.onDumpItemsSuccess(progress))
                //                    } catch {
                //                        print(error)
                //                    }
                //                }
                //            case .onDumpItemsSuccess(let progress):
                //                state.progress = progress
                //                return .send(.clearBucket)
                //            case .clearBucket:
                //                state.bucket = []
                //                return .none
            }
        }
    }
    
    private func getPoints() async throws -> [MapPoint] {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await mapClient.getPoints(token: token)
    }
    
    private func searchPoints(with categories: [String]) async throws -> [MapPoint] {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await mapClient.searchPoints(token: token, categories: categories)
    }
    
    private func openRoute(with anotation: AnnotationMark, in application: MapLink) {
        application.open(with: anotation.coordinate)
    }
    
    private func dumpItems(bucket: [DumpEntity]) async throws -> ProgressResponse {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await bucketClient.dumpItems(token: token, bucket: bucket)
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

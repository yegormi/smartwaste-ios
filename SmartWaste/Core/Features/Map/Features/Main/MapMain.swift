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

@Reducer
struct MapMain: Reducer {
    @Dependency(\.mapClient)      var mapClient
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.bucketClient)   var bucketClient
    
    
    struct State: Equatable {
        @PresentationState var details: AnnotationFeature.State?
        var viewDidAppear = false
        
        var points: [MapPoint]
        var categories: [String]
        var annotation: AnnotationMark?
        
        var emptyAnnotation = AnnotationMark(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            name: "",
            address: "",
            emojiList: []
        )
        var isDumpAllowed = false
    }
    
    enum Action: Equatable {
        case details(PresentationAction<AnnotationFeature.Action>)
        case viewDidAppear
        
        case getPoints
        case searchPoints([String])
        case onGetPointsSuccess([MapPoint])
        
        case onAnnotationTapped(AnnotationMark)
        
        case openRoute(with: AnnotationMark, in: MapLink)
        
        case checkDistance
        case onCheckSuccess(Bool)
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
                state.details = .init(annotation: annotation, isAllowedToDump: false)
                return .none
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
            case .openRoute(let annotation, let app):
                openRoute(with: annotation, in: app)
                return .none
                
                
            case .details:
                return .none
            }
        }
        .ifLet(\.$details, action: \.details) {
            AnnotationFeature()
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
        let manager = LocationManager.shared
        return manager.region.center
    }
    
    private func isWithin(
        radius: Double,
        userLocation: CLLocationCoordinate2D,
        pointLocation: CLLocationCoordinate2D
    ) -> Bool {
        let userLocationCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let pointLocationCLLocation = CLLocation(latitude: pointLocation.latitude, longitude: pointLocation.longitude)
        
        /// Distance in meters
        let distance = userLocationCLLocation.distance(from: pointLocationCLLocation)
        
        return distance <= radius
    }
}

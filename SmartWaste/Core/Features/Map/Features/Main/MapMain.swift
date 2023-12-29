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
        
        var emptyAnnotation = AnnotationMark(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            name: "",
            address: "",
            emojiList: []
        )
        var isDumpAllowed = false
        var isSuccessToastPresented = false
    }
    
    enum Action: Equatable {
        case details(PresentationAction<AnnotationFeature.Action>)
        case successToastPresented(Bool)
        case viewDidAppear
        
        case getPoints
        case searchPoints([String])
        case onGetPointsSuccess([MapPoint])
        
        case onAnnotationTapped(AnnotationMark)        
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .successToastPresented(let isOn):
                state.isSuccessToastPresented = isOn
                return .none
            case .viewDidAppear:
                state.viewDidAppear = true
                guard state.categories.isEmpty else {
                    return .send(.searchPoints(state.categories))
                }
                return .send(.getPoints)
            case .getPoints:
                return .run { send in
                    do {
                        let points = try await getPoints()
                        await send(.onGetPointsSuccess(points))
                    } catch {
                        print(error)
                    }
                }
            case .searchPoints(let categories):
                return .run { send in
                    do {
                        let points = try await searchPoints(with: categories)
                        await send(.onGetPointsSuccess(points))
                    } catch {
                        print(error)
                    }
                }
            case .onGetPointsSuccess(let points):
                state.points = points
                return .none
                
            case .onAnnotationTapped(let annotation):
                state.details = .init(annotation: annotation)
                return .none
                
            case .details(.presented(.clearBucket)):
                return .send(.successToastPresented(true))
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
}

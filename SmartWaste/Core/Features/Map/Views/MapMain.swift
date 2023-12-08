//
//  MapMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct MapMainView: View {
    let store: StoreOf<MapMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Group {
                MapViewRepresentable(points: viewStore.points)
            }
            .onAppear {
                if !viewStore.viewDidAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
        }
        
    }
}

@Reducer
struct MapMain: Reducer {
    @Dependency(\.mapClient) var mapClient
    @Dependency(\.keychainClient) var keychainClient
    
    struct State: Equatable {
        var points: [MapPoint]
        var categories: [String]
        var viewDidAppear = false
    }
    
    enum Action: Equatable {
        case viewDidAppear
        
        case getPoints
        case searchPoints([String])
        case onGetPointsSuccess([MapPoint])
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
}

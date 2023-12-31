//
//  TabsFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.11.2023.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

enum Tab: String, CaseIterable, Equatable {
    case map = "Map"
    case profile = "Profile"
    case bucket = "Bucket"
}

@Reducer
struct TabsFeature: Reducer {
    @Dependency(\.authClient) var authClient
    @Dependency(\.keychainClient) var keychainClient

    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        var token: String = ""
        var user: User?
        var error: FailResponse?

        var map: MapCoordinator.State
        var profile: ProfileCoordinator.State
        var bucket: BucketCoordinator.State
        var selectedTab: Tab

        static func initState(from tab: Tab) -> Self {
            Self(
                map: .initialState,
                profile: .initialState,
                bucket: .initialState,
                selectedTab: tab
            )
        }
        static func initState(from tab: Tab, with categories: [String]) -> Self {
            Self(
                map: .initState(with: categories),
                profile: .initialState,
                bucket: .initialState,
                selectedTab: tab
            )
        }
    }

    enum Action: Equatable {
        case alert(PresentationAction<Alert>)

        case expiredAlertPresented

        case map(MapCoordinator.Action)
        case profile(ProfileCoordinator.Action)
        case bucket(BucketCoordinator.Action)
        case tabSelected(Tab)

        case onAppear
        case getSelf
        case onGetSelfSuccess(User)
        case onGetSelfError(FailResponse)

        case goBackToPrevious

        enum Alert: Equatable {
            case expiredConfirmTapped
        }
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.map, action: /Action.map) {
            MapCoordinator()
        }
        Scope(state: \.profile, action: /Action.profile) {
            ProfileCoordinator()
        }
        Scope(state: \.bucket, action: /Action.bucket) {
            BucketCoordinator()
        }
        Reduce { state, action in
            switch action {
            case .expiredAlertPresented:
                state.alert = AlertState {
                    TextState("Session Expired")
                } actions: {
                    ButtonState(role: .cancel, action: .expiredConfirmTapped) {
                        TextState("OK")
                    }
                } message: {
                    TextState("Please sign in again.")
                }
                return .none

            case .alert(.presented(.expiredConfirmTapped)):
                deleteToken()
                return .none
            case .alert:
                return .none

            case .onAppear:
                return .send(.getSelf)
            case .getSelf:
                state.token = retrieveToken()
                return .run { [token = state.token] send in
                    do {
                        let user = try await getSelf(with: token)
                        await send(.onGetSelfSuccess(user))
                    } catch let ErrorTypes.failedWithResponse(user) {
                        await send(.onGetSelfError(user))
                    } catch {
                        print(error)
                    }
                }
            case .onGetSelfSuccess(let user):
                state.user = user
                return .none
            case .onGetSelfError(let error):
                state.error = error

                switch error.code {
                case
                    RequestError.tokenExpired.code,
                    RequestError.tokenInvalid.code:
                    return .send(.expiredAlertPresented)
                default:
                    return .none
                }

            case .tabSelected(let tab):
                if state.selectedTab == tab {
                    return .send(.goBackToPrevious)
                }
                state.selectedTab = tab
                return .none

            case .map:
                return .none
            case .profile:
                return .none
            case .bucket:
                return .none
            case .goBackToPrevious:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension TabsFeature {
    private func deleteToken() {
        keychainClient.deleteToken()
    }

    private func retrieveToken() -> String {
        keychainClient.retrieveToken()?.accessToken ?? ""
    }

    private func getSelf(with token: String) async throws -> User {
        return try await authClient.performGetSelf(token)
    }
}

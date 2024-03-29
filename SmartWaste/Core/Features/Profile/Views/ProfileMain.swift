//
//  ProfileMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.11.2023.
//

import ComposableArchitecture
import SwiftUI

struct ProfileMainView: View {
    let store: StoreOf<ProfileMain>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                VStack {
                    HStack {
                        ProfileCard(user: viewStore.user)

                        Spacer()

                        Button {
                            viewStore.send(.signOutButtonTapped)
                        } label: {
                            Image(systemName: "arrow.forward.to.line")
                                .padding(10)
                        }
                    }
                    .padding(.vertical, 10)

                    HStack {
                        Text("Level up")
                        Spacer()
                        Text("\(viewStore.user?.completedScore ?? 0)/500")
                    }

                    ProgressView(value: Double(viewStore.user?.completedScore ?? 0), total: 500)
                        .scaleEffect(x: 1, y: 3, anchor: .center)
                }
                .padding([.horizontal, .bottom], 20)

                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .foregroundStyle(Color("QuestGreen"))
                        .overlay(
                            VStack {
                                HStack(spacing: 50) {
                                    StatBox("Buckets", value: viewStore.user?.buckets ?? 0)
                                    StatBox("Level", value: viewStore.user?.level ?? 0)
                                    StatBox("Days", value: viewStore.user?.days ?? 0)
                                }
                                .padding(35)
                                Spacer()
                            }
                        )
                    RoundedRectangle(cornerRadius: 40)
                        .foregroundStyle(Color("Background"))
                        .overlay(
                            VStack(spacing: 0) {
                                Text("Quests")
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(10)
                                ScrollView(showsIndicators: false) {
                                    VStack(spacing: 10) {
                                        ForEach(viewStore.quests ?? []) { quest in
                                            QuestView(quest.name, value: quest.completed, total: quest.total)
                                        }
                                    }
                                    .padding(.bottom, 160)
                                }
                                .padding(.horizontal, 20)
                            }
                        )
                        .offset(y: 150)
                }
                Spacer()
            }
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
            .alert(
                store: self.store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
        }
    }
}

struct ProfileMainView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileMainView(
            store: Store(initialState: ProfileMain.State()) {
                ProfileMain()
                    ._printChanges()
            }
        )
    }
}

@Reducer
struct ProfileMain: Reducer {
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.profileClient) var profileClient

    struct State: Equatable {
        var viewDidAppear = false
        var user: User?
        var quests: [Quest]?
        @PresentationState var alert: AlertState<Action.Alert>?
    }

    enum Action: Equatable {
        case viewDidAppear
        case alert(PresentationAction<Alert>)

        case getSelf
        case onGetSelfSuccess(User)

        case getQuests
        case onGetQuestsSuccess([Quest])

        case signOutButtonTapped
        case onSignOutSuccess

        enum Alert: Equatable {
            case signOutTapped
        }
    }

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .viewDidAppear:
                state.viewDidAppear = true
                return .send(.getSelf)
            case .alert(.presented(.signOutTapped)):
                deleteToken()
                return .send(.onSignOutSuccess)
            case .alert:
                return .none

            case .getSelf:
                return .run { send in
                    do {
                        let user = try await getSelf()
                        await send(.onGetSelfSuccess(user))
                    } catch {
                        print(error)
                    }
                }
            case let .onGetSelfSuccess(user):
                state.user = user
                return .send(.getQuests)

            case .getQuests:
                return .run { send in
                    do {
                        let list = try await getQuests()
                        let quests = list.quests
                        await send(.onGetQuestsSuccess(quests))
                    } catch {
                        print(error)
                    }
                }
            case let .onGetQuestsSuccess(quests):
                state.quests = quests
                return .none
            case .signOutButtonTapped:
                state.alert = AlertState {
                    TextState("Are you sure?")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(role: .destructive, action: .signOutTapped) {
                        TextState("Sign Out")
                    }
                } message: {
                    TextState("Please confirm if you want to sign out")
                }
                return .none
            case .onSignOutSuccess:
                return .none
            }
        }
    }

    private func getSelf() async throws -> User {
        return try await authClient.performGetSelf()
    }

    private func getQuests() async throws -> QuestList {
        return try await profileClient.getQuests()
    }

    private func deleteToken() {
        keychainClient.deleteToken()
    }
}

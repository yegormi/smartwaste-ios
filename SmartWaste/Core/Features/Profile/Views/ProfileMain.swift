//
//  HomeMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.11.2023.
//

import SwiftUI
import ComposableArchitecture

struct ProfileMainView: View {
    let store: StoreOf<ProfileMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
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
                    .padding(.bottom, 10)
                    
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
                        .foregroundStyle(Color.green)
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
                        .foregroundStyle(Color("PrimaryInverted"))
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
                if !viewStore.viewDidAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
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
    }
    
    enum Action: Equatable {
        case viewDidAppear
        
        case getSelf
        case onGetSelfSuccess(User)
        
        case getQuests
        case onGetQuestsSuccess([Quest])
        
        case signOutButtonTapped
        case onSignOutSuccess
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .viewDidAppear:
                state.viewDidAppear = true
                return .send(.getSelf)
            case .getSelf:
                return .run { send in
                    do {
                        let user = try await getSelf()
                        await send(.onGetSelfSuccess(user))
                    } catch {
                        print(error)
                    }
                }
            case .onGetSelfSuccess(let user):
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
            case .onGetQuestsSuccess(let quests):
                state.quests = quests
                return .none
            case .signOutButtonTapped:
                deleteToken()
                return .send(.onSignOutSuccess)
            case .onSignOutSuccess:
                return .none
            }
        }
    }
    
    private func getSelf() async throws -> User {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await authClient.performGetSelf(token)
    }
    
    private func getQuests() async throws -> QuestList {
        let token = keychainClient.retrieveToken()?.accessToken ?? ""
        return try await profileClient.getQuests(token: token)
    }
    
    private func deleteToken() {
        keychainClient.deleteToken()
    }
}

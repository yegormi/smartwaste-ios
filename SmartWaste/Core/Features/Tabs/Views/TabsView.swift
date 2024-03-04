//
//  TabsView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.11.2023.
//

import SwiftUI
import ComposableArchitecture

struct TabsView: View {
    let store: StoreOf<TabsFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HeaderView("♻️ SmartWaste")
                TabView(
                    selection: viewStore.binding(
                        get: \.selectedTab,
                        send: TabsFeature.Action.tabSelected
                    )
                ) {
                    MapCoordinatorView(
                        store: self.store.scope(
                            state: \.map,
                            action: \.map
                        )
                    )
                    .tabItem { Label("Map", systemImage: "map.fill") }
                    .tag(Tab.map)

                    ProfileCoordinatorView(
                        store: self.store.scope(
                            state: \.profile,
                            action: \.profile
                        )
                    )
                    .tabItem { Label("Profile", systemImage: "person.fill") }
                    .tag(Tab.profile)

                    BucketCoordinatorView(
                        store: self.store.scope(
                            state: \.bucket,
                            action: \.bucket
                        )
                    )
                    .tabItem { Label("Bucket", systemImage: "trash.fill") }
                    .tag(Tab.bucket)
                }
                .accentColor(.green)
            }
            .alert(
                store: self.store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView(
            store: Store(initialState: .initState(from: .map)) {
                TabsFeature()
                    ._printChanges()
            }
        )
    }
}

//
//  AuthView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.11.2023.
//

import AlertToast
import ComposableArchitecture
import Reachability
import SwiftUI

struct AuthView: View {
    let store: StoreOf<AuthFeature>
    let reachability = Reachability.shared

    @Namespace private var animation

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack {
                    TitleView("♻️ SmartWaste")

                    HStack {
                        switch viewStore.authType {
                        case .signIn:
                            AuthTitle(authType: .signIn)
                                .padding(.vertical, 30)
                        case .signUp:
                            AuthTitle(authType: .signUp)
                                .padding(.vertical, 30)
                        }
                        Spacer()
                    }

                    VStack(spacing: 15) {
                        if viewStore.authType == .signUp {
                            InputField(
                                label: "Username",
                                text: viewStore.binding(
                                    get: \.username,
                                    send: AuthFeature.Action.usernameChanged
                                ),
                                type: .username,
                                isInvalid: viewStore.usernameError != nil,
                                errorText: viewStore.usernameError
                            )
                        }

                        InputField(
                            label: "Email",
                            text: viewStore.binding(
                                get: \.email,
                                send: AuthFeature.Action.emailChanged
                            ),
                            type: .email,
                            isInvalid: viewStore.emailError != nil,
                            errorText: viewStore.emailError
                        )

                        InputField(
                            label: "Password",
                            text: viewStore.binding(
                                get: \.password,
                                send: AuthFeature.Action.passwordChanged
                            ).removeDuplicates(),
                            type: .password,
                            isInvalid: viewStore.passwordError != nil,
                            errorText: viewStore.passwordError
                        )

                        if viewStore.authType == .signUp {
                            InputField(
                                label: "Confirm Password",
                                text: viewStore.binding(
                                    get: \.confirmPassword,
                                    send: AuthFeature.Action.confirmPasswordChanged
                                ).removeDuplicates(),
                                type: .password,
                                isInvalid:
                                viewStore.password != viewStore.confirmPassword &&
                                    !viewStore.confirmPassword.isEmpty
                            )
                            .transition(.scale)
                        }
                    }

                    AuthButton(authType: viewStore.authType, isLoading: viewStore.isLoading, color: .green) {
                        if reachability.currentPath.isReachable {
                            viewStore.send(.authButtonTapped)
                        } else {
                            viewStore.send(.toastToggled)
                        }
                    }
                    .scaleButton()
                    .frame(height: 45)
                    .disabled(!viewStore.isLoginAllowed)
                    .opacity(!viewStore.isLoginAllowed ? 0.5 : 1)
                    .padding(.top, 20)

                    AuthToggleButton(authType: viewStore.authType) {
                        viewStore.send(.toggleButtonTapped, animation: .easeInOut)
                    }
                    .padding(.vertical, 20)
                    .animation(.default, value: viewStore.authType)
                    .matchedGeometryEffect(id: "authToggle", in: animation)

                    Spacer()
                }
                .padding(30)
            }
            .toast(isPresenting: viewStore.binding(
                get: \.isToastPresented,
                send: AuthFeature.Action.toastToggled
            )) {
                AlertToast(displayMode: .hud, type: .error(Color.red), title: "No internet connection")
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(
            store: Store(initialState: AuthFeature.State()) {
                AuthFeature()
                    ._printChanges()
            }
        )
    }
}

//
//  AuthFeature.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.11.2023.
//

import Alamofire
import ComposableArchitecture
import Foundation

@Reducer
struct AuthFeature: Reducer {
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.authClient) var authClient

    struct State: Equatable {
        var username: String = ""
        var email: String = ""
        var password: String = ""
        var confirmPassword: String = ""

        var usernameError: String?
        var emailError: String?
        var passwordError: String?

        var authType: AuthType = .signIn
        var response: AuthResponse?
        var failResponse: FailResponse?

        var isLoading = false
        var isToastPresented = false

        var isAbleToSignIn: Bool {
            !email.isEmpty && !password.isEmpty
        }

        var isAbleToSignUp: Bool {
            !username.isEmpty && !email.isEmpty &&
                !password.isEmpty && !confirmPassword.isEmpty &&
                password == confirmPassword
        }

        var isLoginAllowed: Bool {
            authType == .signIn ? isAbleToSignIn && !isLoading : isAbleToSignUp && !isLoading
        }

        mutating func resetErrors() {
            usernameError = nil
            emailError = nil
            passwordError = nil
        }
    }

    enum Action: Equatable {
        case usernameChanged(String)
        case emailChanged(String)
        case passwordChanged(String)
        case confirmPasswordChanged(String)

        case toggleButtonTapped
        case authButtonTapped
        case signIn
        case signUp

        case authResponse(Result<AuthResponse, FailResponse>)

        case toastToggled
    }

    private enum CancelID { case auth }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .usernameChanged(current):
                state.username = current
                state.usernameError = nil
                return .none
            case let .emailChanged(current):
                state.email = current
                state.emailError = nil
                return .none
            case let .passwordChanged(current):
                state.password = current
                state.passwordError = nil
                return .none
            case let .confirmPasswordChanged(current):
                state.confirmPassword = current
                return .none
            case .toggleButtonTapped:
                state.authType.toggle()

                state.failResponse = nil
                state.emailError = nil
                state.usernameError = nil
                state.passwordError = nil

                state.isLoading = false

                return .cancel(id: CancelID.auth)

            case .signIn:
                let email = state.email
                let password = state.password

                return .run { send in
                    do {
                        let result = try await signIn(
                            email: email,
                            password: password
                        )
                        await send(.authResponse(.success(result)))
                    } catch let ErrorTypes.failedWithResponse(error) {
                        await send(.authResponse(.failure(error)))
                    } catch {
                        print(error)
                    }
                }
                .cancellable(id: CancelID.auth, cancelInFlight: true)

            case .signUp:
                let email = state.email
                let password = state.password
                let username = state.username

                return .run { send in
                    do {
                        let result = try await signUp(
                            username: username,
                            email: email,
                            password: password
                        )
                        await send(.authResponse(.success(result)))
                    } catch let ErrorTypes.failedWithResponse(error) {
                        await send(.authResponse(.failure(error)))
                    } catch {
                        print(error)
                    }
                }
                .cancellable(id: CancelID.auth, cancelInFlight: true)

            case .authButtonTapped:
                state.isLoading = true

                if !Validation.isValidUsername(with: state.username) && state.authType == .signUp {
                    state.usernameError = "Invalid username"
                    state.isLoading = false
                    return .none
                }
                if !Validation.isValidEmail(with: state.email) {
                    state.emailError = "Invalid email"
                    state.isLoading = false
                    return .none
                }

                switch state.authType {
                case .signIn:
                    return .send(.signIn)
                case .signUp:
                    return .send(.signUp)
                }
            case let .authResponse(.success(response)):
                state.response = response
                state.failResponse = nil
                state.isLoading = false
                keychainClient.saveToken(response)
                return .none

            case let .authResponse(.failure(error)):
                state.failResponse = error
                state.isLoading = false

                state.resetErrors()

                switch error.code {
                case RequestError.usernameNotUnique.code:
                    state.usernameError = RequestError.usernameNotUnique.string
                case RequestError.userNotFound.code:
                    state.emailError = RequestError.userNotFound.string
                case RequestError.emailNotUnique.code:
                    state.emailError = RequestError.emailNotUnique.string
                case RequestError.invalidPassword.code:
                    state.passwordError = RequestError.invalidPassword.string
                default:
                    break
                }

                return .none

            case .toastToggled:
                state.isToastPresented.toggle()
                return .none
            }
        }
    }
}

extension AuthFeature {
    private func signIn(email: String, password: String) async throws -> AuthResponse {
        return try await authClient.performSignIn(email, password)
    }

    private func signUp(username: String, email: String, password: String) async throws -> AuthResponse {
        return try await authClient.performSignUp(username, email, password)
    }
}

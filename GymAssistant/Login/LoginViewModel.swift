//
//  LoginViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    private let authManager: AuthManager
        
    @Published var signInModel: SignIn = SignIn(email: "",
                                                password: "")
    @Published var forgotPassword: String = ""
    @Published var showForgotPassword: Bool = false
    @Published var alert: CustomError? = nil
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func signIn() async {
        do{
            try signInModel.validate()
            try await authManager.signIn(singIn: signInModel)
            signInModel.clear()
        } catch {
            handleError(error, title: "Login Error")
        }
    }
    
    func resetPassword(email: String) async {
        do{
            try await authManager.resetPassword(email: email)
            showForgotPassword = false
        } catch {
            handleError(error, title: "Reset Error")
        }
    }
    
    private func handleError(_ error: Error, title: String = "Error", subtitle: String = "Try again") {
        switch error {
        case let error as CustomError:
            alert = error
        case let error as AppAuthError:
            alert = .authError(appAuthError: error)
        default:
            alert = CustomError.customError(title: title,
                                            subtitle: subtitle)
        }
    }
}

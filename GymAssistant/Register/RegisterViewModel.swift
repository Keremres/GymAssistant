//
//  RegisterViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import Foundation

@MainActor
final class RegisterViewModel: ObservableObject {
    
    private let authManager: AuthManager = AppContainer.shared.authManager
    
    @Published var register: Register = Register(email: "",
                                                 password: "",
                                                 verifyPassword: "",
                                                 firstName: "",
                                                 lastName: "")
    @Published var alert: CustomError? = nil
    
    func createUser() async {
        do{
            try register.validate()
            try await authManager.signUp(register: register)
            register.clear()
        } catch {
            handleError(error, title: "Register Error")
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

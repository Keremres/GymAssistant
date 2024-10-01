//
//  LoginViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var forgotPassword: String = ""
    
    @Published var showForgotPassword: Bool = false
        
    @Published var alert: CustomError? = nil
    
    func signIn() async throws {
        guard validate() else { return }
        do{
            try await AuthService.shared.login(withEmail: email, password: password)
        }catch let error as AppAuthError{
            alert = .authError(appAuthError: error)
        }catch{
            alert = CustomError.customError(title: "Login Error", subtitle: "Try again")
        }
    }
    
    func resetPassword(email: String) async throws {
        do{
            try await AuthService.shared.resetPassword(email: email)
            showForgotPassword = false
        }catch let error as AppAuthError{
            alert = .authError(appAuthError: error)
        }catch{
            alert = CustomError.customError(title: "Reset Error", subtitle: "Try again")
        }
    }
    
    func validate() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            alert = CustomError.customError(title: LoginAlert.enterEmail.title, subtitle: LoginAlert.enterEmail.subtitle)
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            alert = CustomError.customError(title: LoginAlert.validEmail.title, subtitle: LoginAlert.validEmail.subtitle)
            return false
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            alert = CustomError.customError(title: LoginAlert.enterPassword.title, subtitle: LoginAlert.enterPassword.subtitle)
            return false
        }
        guard password.count >= 6 else{
            alert = CustomError.customError(title: LoginAlert.characters.title, subtitle: LoginAlert.characters.subtitle)
            return false
        }
        
        return true
    }
}

enum LoginAlert{
    case enterEmail
    case validEmail
    case enterPassword
    case characters
    
    var title: String{
        switch self{
        case .enterEmail:
            "Email Error"
        case .validEmail:
            "Email Error"
        case .enterPassword:
            "Password Error"
        case .characters:
            "Password Error"
        }
    }
    var subtitle: String{
        switch self{
        case .enterEmail:
            "Plase enter email"
        case .validEmail:
            "Plase enter a valid email"
        case .enterPassword:
            "Plase enter password"
        case .characters:
            "Plase enter a password longer than 6 characters"
        }
    }
}

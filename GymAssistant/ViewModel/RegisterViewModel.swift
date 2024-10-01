//
//  RegisterViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import Foundation

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var verifyPassword: String = ""
    
    @Published var alert: CustomError? = nil
    
    func createUser() async throws {
        guard validate() else { return }
        do{
            try await AuthService.shared.createUser(email: email, password: password, username: username)
                self.username = ""
                self.email = ""
                self.password = ""
                self.verifyPassword = ""
        }catch let error as AppAuthError{
            alert = CustomError.authError(appAuthError: error)
        }catch{
            alert = CustomError.customError(title: "Register Error", subtitle: "Try again")
        }
    }
    
    func validate() -> Bool {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            alert = CustomError.customError(title: RegisterAlert.username.title, subtitle: RegisterAlert.username.subtitle)
            return false
        }
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            alert = CustomError.customError(title: RegisterAlert.enterEmail.title, subtitle: RegisterAlert.enterEmail.subtitle)
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            alert = CustomError.customError(title: RegisterAlert.validEmail.title, subtitle: RegisterAlert.validEmail.subtitle)
            return false
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            alert = CustomError.customError(title: RegisterAlert.enterPassword.title, subtitle: RegisterAlert.enterPassword.subtitle)
            return false
        }
        guard password.count >= 6 else{
            alert  = CustomError.customError(title: RegisterAlert.characters.title, subtitle: RegisterAlert.characters.subtitle)
            return false
        }
        guard password == verifyPassword else {
            alert = CustomError.customError(title: RegisterAlert.notMatch.title, subtitle: RegisterAlert.notMatch.subtitle)
            return false
        }
        
        return true
    }
}

enum RegisterAlert{
    
    case username
    case enterEmail
    case validEmail
    case enterPassword
    case characters
    case notMatch
    
    var title: String{
        switch self{
        case .username:
            "Username Error"
        case .enterEmail:
            "Email Error"
        case .validEmail:
            "Email Error"
        case .enterPassword:
            "Password Error"
        case .characters:
            "Password Error"
        case .notMatch:
            "Password Error"
        }
    }
    var subtitle: String{
        switch self{
        case .username:
            "Plase enter username"
        case .enterEmail:
            "Plase enter email"
        case .validEmail:
            "Plase enter a valid email"
        case .enterPassword:
            "Plase enter password"
        case .characters:
            "Plase enter a password longer than 6 characters"
        case .notMatch:
            "Your password does not match"
        }
    }
}

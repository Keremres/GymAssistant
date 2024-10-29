//
//  SignIn.swift
//  META
//
//  Created by Kerem RESNENLİ on 7.10.2024.
//

import Foundation

struct SignIn {
    var email: String
    var password: String
    
    mutating func clear() {
        self.email = ""
        self.password = ""
    }
    
    func validate() throws {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CustomError.customError(title: LoginAlert.enterEmail.title,
                                          subtitle: LoginAlert.enterEmail.subtitle)
        }
        guard email.contains("@") && email.contains(".") else {
            throw CustomError.customError(title: LoginAlert.validEmail.title,
                                          subtitle: LoginAlert.validEmail.subtitle)
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CustomError.customError(title: LoginAlert.enterPassword.title,
                                          subtitle: LoginAlert.enterPassword.subtitle)
        }
        guard password.count >= 6 else{
            throw CustomError.customError(title: LoginAlert.characters.title,
                                          subtitle: LoginAlert.characters.subtitle)
        }
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

//
//  Register.swift
//  META
//
//  Created by Kerem RESNENLİ on 7.10.2024.
//

import Foundation

struct Register {
    var email: String
    var password: String
    var verifyPassword: String
    var firstName: String
    var lastName: String
    
    mutating func clear() {
        self.email = ""
        self.password = ""
        self.verifyPassword = ""
        self.firstName = ""
        self.lastName = ""
    }
    
    func validate() throws {
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CustomError.customError(title: RegisterAlert.firstName.title,
                                          subtitle: RegisterAlert.firstName.subtitle)
        }
        guard !lastName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CustomError.customError(title: RegisterAlert.lastName.title,
                                          subtitle: RegisterAlert.lastName.subtitle)
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CustomError.customError(title: RegisterAlert.enterEmail.title,
                                          subtitle: RegisterAlert.enterEmail.subtitle)
        }
        guard email.contains("@") && email.contains(".") else {
            throw CustomError.customError(title: RegisterAlert.validEmail.title,
                                          subtitle: RegisterAlert.validEmail.subtitle)
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CustomError.customError(title: RegisterAlert.enterPassword.title,
                                          subtitle: RegisterAlert.enterPassword.subtitle)
        }
        guard password.count >= 6 else{
            throw CustomError.customError(title: RegisterAlert.characters.title,
                                          subtitle: RegisterAlert.characters.subtitle)
        }
        guard password == verifyPassword else {
            throw CustomError.customError(title: RegisterAlert.notMatch.title,
                                          subtitle: RegisterAlert.notMatch.subtitle)
        }
    }
}

enum RegisterAlert{
    
    case firstName
    case lastName
    case enterEmail
    case validEmail
    case enterPassword
    case characters
    case notMatch
    
    var title: String{
        switch self{
        case .firstName:
            "FirstName Error"
        case .lastName:
            "LastName Error"
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
        case .firstName:
            "Plase enter firstName"
        case .lastName:
            "Plase enter lastName"
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

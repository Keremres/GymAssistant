//
//  LocaleKeys.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 5.02.2025.
//

import Foundation

enum LocaleKeys {
    enum Tab: String, Localizable {
        case home = "home"
        case person = "person"
        case search = "search"
    }
    
    enum Login: String, Localizable {
        case email = "email"
        case password = "password"
        case login = "login"
        case loginText = "loginText"
        case signUpText = "signUpText"
        case signUp = "signUp"
        case forgotPassword = "forgotPassword"
        
        enum Forgot: String, Localizable {
            case resetPassword = "resetPassword"
            case pleaseEmail = "pleaseEmail"
        }
    }
    
    enum Register: String, Localizable {
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case password = "password"
        case verifyPassword = "verifyPassword"
        case signUp = "signUp"
    }
    
    enum Create: String, Localizable {
        case new = "new"
        case delete = "delete"
        case createTitle = "createTitle"
        case createDayTitle = "createDayTitle"
        case programName = "programName"
        case chooseClass = "chooseClass"
        case chooseDay = "chooseDay"
        case set = "set"
        case repeatText = "repeatText"
        case repeatInterval = "repeatInterval"
        case weight = "weight"
        case exercise = "exercise"
        case newExercise = "newExercise"
        case exerciseName = "exerciseName"
    }
    
    enum Person: String, Localizable {
        case account = "account"
        case program = "program"
        case programHistory = "programHistory"
        case out = "out"
        case delete = "delete"
        case empty = "empty"
        case emptyText = "emptyText"
    }
    
    enum Search: String, Localizable {
        case searchText = "searchText"
    }
    
    enum Home: String, Localizable {
        case step = "step"
        case stepText = "stepText"
        case calories = "calories"
        case caloriesText = "caloriesText"
        case goal = "goal"
        case emptyHome = "emptyHome"
        case emptyHomeText = "emptyHomeText"
        case create = "create"
        case select = "select"
        case date = "date"
        case weight = "weight"
        case selectDate = "selectDate"
        case stepsGoal = "stepsGoal"
        case caloriesGoal = "caloriesGoal"
        case goalEnter = "goalEnter"
    }
    
    enum Dialog: String, Localizable {
        case save = "save"
        case cancel = "cancel"
        case publish = "publish"
        case areYouSure = "areYouSure"
        case programOut = "programOut"
        case useProgram = "useProgram"
        case deleteAccount = "deleteAccount"
        case signOut = "signOut"
        case programOutText = "programOutText"
        case deleteAccountText = "deleteAccountText"
        case signOutText = "signOutText"
    }
    
    enum Widget: String, Localizable {
        case description = "description"
    }
}

protocol Localizable: RawRepresentable where RawValue == String {
    var localized: String { get }
    func localized(with arguments: CVarArg...) -> String
}

extension Localizable {
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}

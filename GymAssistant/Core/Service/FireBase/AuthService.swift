//
//  AuthService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.07.2024.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift

class AuthService{
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    static let shared = AuthService()
    
    init() {
        Task{ try await loadUserData() }
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await loadUserData()
        }catch{
            let error = error as NSError
            switch error.code{
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw AppAuthError.emailAlreadyInUse
            case AuthErrorCode.invalidEmail.rawValue:
                throw AppAuthError.invalidEmail
            case AuthErrorCode.wrongPassword.rawValue:
                throw AppAuthError.wrongPassword
            case AuthErrorCode.tooManyRequests.rawValue:
                throw AppAuthError.tooManyRequests
            default:
                throw AppAuthError.networkError
            }
        }
    }
    
    @MainActor
    func createUser(email: String, password: String, username: String) async throws {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            await uploadUserData(uid: result.user.uid, username: username, email: email)
            try await loadUserData()
        }catch{
            let error = error as NSError
            switch error.code{
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw AppAuthError.emailAlreadyInUse
            case AuthErrorCode.invalidEmail.rawValue:
                throw AppAuthError.invalidEmail
            case AuthErrorCode.wrongPassword.rawValue:
                throw AppAuthError.wrongPassword
            case AuthErrorCode.tooManyRequests.rawValue:
                throw AppAuthError.tooManyRequests
            default:
                throw AppAuthError.networkError
            }
        }
    }
    
    func uploadUserData(uid: String, username: String, email: String) async {
        let user = User(id: uid, username: username, email: email)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try? await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
    }
    
    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await Firestore.firestore().collection("users").document(currentUid).getDocument()
        self.currentUser = try? snapshot.data(as: User.self)
    }
    @MainActor
    func signout() {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
    }
    
    func resetPassword(email: String) async throws {
        do{
            try await Auth.auth().sendPasswordReset(withEmail: email)
        }catch{
            let error = error as NSError
            switch error.code{
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw AppAuthError.emailAlreadyInUse
            case AuthErrorCode.invalidEmail.rawValue:
                throw AppAuthError.invalidEmail
            case AuthErrorCode.wrongPassword.rawValue:
                throw AppAuthError.wrongPassword
            case AuthErrorCode.tooManyRequests.rawValue:
                throw AppAuthError.tooManyRequests
            default:
                throw AppAuthError.networkError
            }
        }
    }
}

enum AppAuthError: Error{
    case emailAlreadyInUse
    case invalidEmail
    case wrongPassword
    case tooManyRequests
    case networkError
    
    var localizedDescription: String{
        switch self {
        case .emailAlreadyInUse:
            "This e-mail address is already in use. Please try again with the correct password."
        case .invalidEmail:
            "Please enter a valid email address."
        case .wrongPassword:
            "The password you entered is incorrect. Please try again."
        case .tooManyRequests:
            "You have made too many requests in a short period of time. Please wait a while before trying again."
        case .networkError:
            "There was an issue with the network connection. Please try again."
        }
    }
}

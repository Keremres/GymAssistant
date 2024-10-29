//
//  FirebaseAuthService.swift
//  META
//
//  Created by Kerem RESNENLİ on 5.10.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase

struct FirebaseAuthService: AuthService {
    
    private let userCollection: CollectionReference = Firestore.firestore().collection(FirebasePath.users)
    
    init() {}
    
    func getAuthenticatedUser() -> AuthInfo? {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return AuthInfo(user: currentUser)
    }
    
    func addAuthenticatedUserListener() -> AsyncStream<AuthInfo?> {
        AsyncStream { continuation in
            _ = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = AuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
        }
    }
    
    func singUp(register: Register) async throws {
        do{
            let result = try await Auth.auth().createUser(withEmail: register.email,
                                                          password: register.password)
            let userInfo = UserInfo(authInfo: AuthInfo(user: result.user),
                                    firstName: register.firstName,
                                    lastName: register.lastName,
                                    creationDate: Date(),
                                    lastLoginDate: Date())
            try await uploadUserData(userInfo: userInfo)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signIn(signIn: SignIn) async throws {
        do{
            try await Auth.auth().signIn(withEmail: signIn.email,
                                         password: signIn.password)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AppAuthError.userNotFound
        }
        try await userCollection.deleteDocument(id: user.uid)
        try await user.delete()
    }
    
    func resetPassword(email: String) async throws {
        do{
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    private func uploadUserData(userInfo: UserInfo) async throws {
        try await userCollection.setDocument(document: userInfo)
    }
    
    private func mapFirebaseError(_ error: Error) -> AppAuthError {
        let error = error as NSError
        switch error.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.tooManyRequests.rawValue:
            return .tooManyRequests
        default:
            return .networkError
        }
    }
}

enum AppAuthError: ErrorAlert{
    case emailAlreadyInUse
    case invalidEmail
    case wrongPassword
    case tooManyRequests
    case networkError
    case userNotFound
    
    var title: String{
        switch self{
        case .emailAlreadyInUse:
            "Email Already In Use"
        case .invalidEmail:
            "Invalid Email"
        case .wrongPassword:
            "Wrong Password"
        case .tooManyRequests:
            "Too Many Requests"
        case .networkError:
            "Network Error"
        case .userNotFound:
            "User Not Found"
        }
    }
    
    var subtitle: String?{
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
        case .userNotFound:
            "The user you are trying to access does not exist."
        }
    }
}

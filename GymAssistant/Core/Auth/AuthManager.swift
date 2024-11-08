//
//  AuthManager.swift
//  META
//
//  Created by Kerem RESNENLİ on 5.10.2024.
//

import Foundation

@MainActor
final class AuthManager: ObservableObject {
    private let service: AuthService
    
    @Published private(set) var authInfo: AuthInfo?
    
    init(service: AuthService) {
        self.service = service
        self.authInfo = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    
    /// Retrieves the authenticated user's ID if available.
    /// - Throws: `AuthenticationError.notSignedIn` if there is no authenticated user.
    func getAuthId() throws -> String {
        guard let uid = authInfo?.id else {
            throw AuthenticationError.notSignedIn
        }
        return uid
    }
    
    /// Listens for changes in authentication state asynchronously and updates `authInfo`.
    /// Uses a Task to monitor `service.addAuthenticatedUserListener()` and updates authInfo when changes occur.
    private func addAuthListener() {
        Task{
            for await auth in service.addAuthenticatedUserListener() {
                self.authInfo = auth
            }
        }
    }
    
    /// Sends a password reset request to the provided email address.
    /// - Parameter email: The email address to send the reset password link to.
    func resetPassword(email: String) async throws {
        try await service.resetPassword(email: email)
    }
    
    /// Registers a new user with the provided registration details.
    /// - Parameter register: Contains user information needed for registration.
    func signUp(register: Register) async throws {
        try await service.singUp(register: register)
    }
    
    /// Signs in a user with the provided login credentials.
    /// - Parameter signIn: The user’s sign-in credentials.
    func signIn(signIn: SignIn) async throws {
        try await service.signIn(signIn: signIn)
    }
    
    /// Signs out the current user and clears `authInfo`.
    func signOut() throws {
        try service.signOut()
        self.authInfo = nil
    }
    
    /// Deletes the currently authenticated user’s account and clears `authInfo`.
    func deleteAccount() async throws {
        try await service.deleteAccount()
        self.authInfo = nil
    }
}

enum AuthenticationError: Error {
    case notSignedIn
}

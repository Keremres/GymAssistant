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
    
    func getAuthId() throws -> String {
        guard let uid = authInfo?.id else {
            throw AuthenticationError.notSignedIn
        }
        return uid
    }
    
    private func addAuthListener() {
        Task{
            for await auth in service.addAuthenticatedUserListener() {
                self.authInfo = auth
            }
        }
    }
    
    func resetPassword(email: String) async throws {
        do{
            try await service.resetPassword(email: email)
        } catch {
            throw error
        }
    }
    
    func signUp(register: Register) async throws {
        do{
            try await service.singUp(register: register)
        } catch {
            throw error
        }
    }
    
    func signIn(singIn: SignIn) async throws {
        do{
            try await service.signIn(signIn: singIn)
        } catch {
            throw error
        }
    }
    
    func signOut() throws {
        do{
            try service.signOut()
            self.authInfo = nil
        } catch {
            throw error
        }
    }
    
    func deleteAccount() async throws {
        do{
            try await service.deleteAccount()
            self.authInfo = nil
        } catch {
            throw error
        }
    }
}

enum AuthenticationError: Error {
    case notSignedIn
}

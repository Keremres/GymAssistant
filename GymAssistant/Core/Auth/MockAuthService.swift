//
//  MockAuthService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 14.10.2024.
//

import Foundation
import Combine

final class MockAuthService: AuthService {
    private var register: Register?
    @Published private var authInfo: AuthInfo?
    var shouldThrowError: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    
    func getAuthenticatedUser() -> AuthInfo? {
        self.authInfo
    }
    
    func addAuthenticatedUserListener() -> AsyncStream<AuthInfo?> {
        return AsyncStream { continuation in
            self.$authInfo.sink { authInfo in
                continuation.yield(authInfo)
            }
            .store(in: &self.cancellables)
        }
    }
    
    func singUp(register: Register) async throws {
        try checkShouldThrowError()
        self.register = register
        self.authInfo = AuthInfo.mockRegister(register: register)
    }
    
    func signIn(signIn: SignIn) async throws {
        try checkShouldThrowError()
        try checkRegister()
        guard register?.email == signIn.email else {
            throw CustomError.customError(title: "Email",
                                          subtitle: "Email not found")
        }
        guard register?.password == signIn.password else {
            throw CustomError.customError(title: "Password",
                                          subtitle: "Password mismatch")
        }
    }
    
    func signOut() throws {
        try checkShouldThrowError()
        try checkAuthInfo()
        self.authInfo = nil
    }
    
    func deleteAccount() async throws {
        try checkShouldThrowError()
        try checkRegister()
        try checkAuthInfo()
        self.register = nil
        self.authInfo = nil
    }
    
    func resetPassword(email: String) async throws {
        try checkShouldThrowError()
        guard register?.email == email else {
            throw CustomError.customError(title: "Email",
                                          subtitle: "Email not found")
        }
    }
    
    private func checkShouldThrowError() throws {
        if shouldThrowError {
            throw CustomError.customError(title: "Error",
                                          subtitle: "Error")
        }
    }
    
    private func checkAuthInfo() throws {
        guard self.authInfo != nil else {
            throw CustomError.customError(title: "AuthInfo",
                                          subtitle: "AuthInfo not found")
        }
    }
    
    private func checkRegister() throws {
        guard self.register != nil else {
            throw CustomError.customError(title: "Register",
                                          subtitle: "Register not found")
        }
    }
}

//
//  AuthService.swift
//  META
//
//  Created by Kerem RESNENLİ on 5.10.2024.
//

import Foundation

protocol AuthService {
    func getAuthenticatedUser() -> AuthInfo?
    func addAuthenticatedUserListener() -> AsyncStream<AuthInfo?>
    func singUp(register: Register) async throws
    func signIn(signIn: SignIn) async throws
    func signOut() throws
    func deleteAccount() async throws
    func resetPassword(email: String) async throws
}

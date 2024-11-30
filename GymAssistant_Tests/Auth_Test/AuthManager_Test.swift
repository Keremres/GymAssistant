//
//  AuthManager_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 6.11.2024.
//

import XCTest
import Combine
@testable import GymAssistant

@MainActor
final class AuthManager_Test: XCTestCase {
    private var authManager: AuthManager!
    private var mockAuthService: MockAuthService!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthService()
        authManager = AuthManager(service: mockAuthService)
    }
    
    override func tearDownWithError() throws {
        cancellables.removeAll()
        cancellables = []
        authManager = nil
        mockAuthService = nil
    }
    
    func test_SignUp_Success() async throws {
        // Given
        let register = Register.mockRegister()
        
        // When
        try await authManager.signUp(register: register)
        
        let expectation = XCTestExpectation(description: "Wait for authInfo to be set")
        
        // Listen for authInfo update
        authManager.$authInfo
            .dropFirst()
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(authManager.authInfo, "AuthInfo should not be nil after successful sign-up")
        XCTAssertEqual(authManager.authInfo?.email, register.email, "AuthInfo email should match registered email")
    }
    
    func test_SignIn_Success() async throws {
        // Given
        let register = Register.mockRegister()
        try await authManager.signUp(register: register)
        
        let signIn = SignIn(email: register.email, password: register.password)
        
        // When
        try await authManager.signIn(signIn: signIn)
        
        // Then
        XCTAssertNotNil(authManager.authInfo, "AuthInfo should not be nil after successful sign-in")
    }
    
    func test_SignIn_Failure_IncorrectPassword() async throws {
        // Given
        let register = Register.mockRegister()
        try await authManager.signUp(register: register)
        
        let signIn = SignIn(email: register.email, password: "wrongpassword")
        
        // When & Then
        do {
            try await authManager.signIn(signIn: signIn)
            XCTFail("Expected an error to be thrown, but signIn succeeded")
        } catch let error as CustomError {
            XCTAssertEqual(error.localizedDescription,
                           CustomError.customError(title: "Password", subtitle: "Password mismatch").localizedDescription)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func test_SignOut_Success() async throws {
        // Given
        let register = Register.mockRegister()
        try await authManager.signUp(register: register)
        
        // When
        try authManager.signOut()
        
        // Then
        XCTAssertNil(authManager.authInfo, "AuthInfo should be nil after signing out")
    }
    
    func test_ResetPassword_Success() async throws {
        // Given
        let register = Register.mockRegister()
        try await authManager.signUp(register: register)
        
        // When
        try await authManager.resetPassword(email: register.email)
        
        // Then
        XCTAssertNotNil(authManager.authInfo, "AuthInfo should remain after password reset request")
    }
    
    func test_DeleteAccount_Success() async throws {
        // Given
        let register = Register.mockRegister()
        try await authManager.signUp(register: register)
        
        // When
        try await authManager.deleteAccount()
        
        // Then
        XCTAssertNil(authManager.authInfo, "AuthInfo should be nil after account deletion")
    }
    
    func test_GetAuthId_Success() async throws {
        // Given
        let register = Register.mockRegister()
        try await authManager.signUp(register: register)
        
        let expectation = XCTestExpectation(description: "Wait for authInfo to be set")
        
        // Listen for authInfo update
        authManager.$authInfo
            .dropFirst()
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // When
        let authId = try authManager.getAuthId()
        
        // Then
        XCTAssertEqual(authId, authManager.authInfo?.id, "Auth ID should match the authInfo ID")
    }
    
    func test_GetAuthId_Failure_NotSignedIn() {
        // When & Then
        XCTAssertThrowsError(try authManager.getAuthId()) { error in
            XCTAssertEqual(error as? AuthenticationError, AuthenticationError.notSignedIn, "Should throw notSignedIn error when authInfo is nil")
        }
    }
}

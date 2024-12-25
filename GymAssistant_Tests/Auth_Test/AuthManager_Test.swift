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
    var authManager: AuthManager!
    var mockAuthService: MockAuthService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        self.mockAuthService = MockAuthService()
        self.cancellables = Set<AnyCancellable>()
        self.authManager = AuthManager(service: mockAuthService)
    }
    
    override func tearDown() {
        self.cancellables = nil
        self.authManager = nil
        self.mockAuthService = nil
        super.tearDown()
    }
    
    func test_SignUp_Success() async {
        // Given
        let register = Register.mockRegister()
        let expectation = XCTestExpectation(description: "Wait for authInfo to be set")
        
        // Listen for authInfo update
        authManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await authManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertNotNil(authManager.authInfo, "AuthInfo should not be nil after successful sign-up")
        XCTAssertEqual(authManager.authInfo?.email, register.email, "AuthInfo email should match registered email")
    }
    
    func test_SignIn_Success() async {
        // Given
        let register = Register.mockRegister()
        let signIn = SignIn(email: register.email, password: register.password)
        let expectation = XCTestExpectation(description: "Wait for authInfo to be set")
        let expectation2 = XCTestExpectation(description: "Wait for signIn to be set")
        
        authManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        do{
            try await authManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        
        do{
            try authManager.signOut()
            XCTAssertNil(authManager.authInfo, "AuthInfo should be nil after successful sign-out")
        } catch {
            XCTFail("SignOut should not throw error")
        }
        
        authManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await authManager.signIn(signIn: signIn)
        } catch {
            XCTFail("SignIn should not throw error")
        }
        
        // Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNotNil(authManager.authInfo, "AuthInfo should not be nil after successful sign-in")
    }
    
    func test_SignIn_Failure_IncorrectPassword() async {
        // Given
        let register = Register.mockRegister()
        let signIn = SignIn(email: register.email, password: "wrongpassword")
        let expectation = XCTestExpectation(description: "Wait for signUp to be set")
        authManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await authManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        do{
            try authManager.signOut()
            XCTAssertNil(authManager.authInfo, "AuthInfo should be nil after successful sign-out")
        } catch {
            XCTFail("SignOut should not throw error")
        }
        
        // When & Then
        do {
            try await authManager.signIn(signIn: signIn)
            XCTFail("Expected an error to be thrown, but signIn succeeded")
        } catch let error as AppAuthError {
            XCTAssertEqual(error.localizedDescription,
                           AppAuthError.wrongPassword.localizedDescription)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func test_SignOut_Success() async {
        // Given
        let register = Register.mockRegister()
        let expectation = XCTestExpectation(description: "Wait for signUp to be set")
        authManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await authManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        
        // When
        do{
            try authManager.signOut()
        } catch {
            XCTFail("SignOut should not throw error")
        }
        
        // Then
        XCTAssertNil(authManager.authInfo, "AuthInfo should be nil after signing out")
    }
    
    func test_ResetPassword_Success() async {
        // Given
        let register = Register.mockRegister()
        let expectation = XCTestExpectation(description: "Wait for signUp to be set")
        authManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await authManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        
        // When
        do{
            try await authManager.resetPassword(email: register.email)
        } catch {
            XCTFail("ResetPassword should not throw error")
        }
        
        // Then
        XCTAssertNotNil(authManager.authInfo, "AuthInfo should remain after password reset request")
    }
    
    func test_DeleteAccount_Success() async {
        // Given
        let register = Register.mockRegister()
        let expectation = XCTestExpectation(description: "Wait for signUp to be set")
        let expectation2 = XCTestExpectation(description: "Wait for deleteAccount to be set")
        authManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await authManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        
        authManager.$authInfo
            .sink { authInfo in
                if authInfo == nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await authManager.deleteAccount()
        } catch {
            XCTFail("DeleteAccount should not throw error")
        }
        
        // Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNil(authManager.authInfo, "AuthInfo should be nil after account deletion")
        XCTAssertNil(mockAuthService.register)
    }
    
    func test_GetAuthId_Success() async {
        // Given
        let register = Register.mockRegister()
        let expectation = XCTestExpectation(description: "Wait for authInfo to be set")
        authManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await authManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // When & Then
        do{
            let authId = try authManager.getAuthId()
            XCTAssertEqual(mockAuthService.authInfo?.id, authId)
            XCTAssertEqual(authId, authManager.authInfo?.id, "Auth ID should match the authInfo ID")
        } catch {
            XCTFail("GetAuthId should not throw error")
        }
    }
    
    func test_GetAuthId_Failure_NotSignedIn() {
        // When & Then
        do{
            let _ = try authManager.getAuthId()
            XCTFail("Should throw notSignedIn error when authInfo is nil")
        } catch {
            XCTAssertEqual(error as? AuthenticationError, AuthenticationError.notSignedIn, "Should throw notSignedIn error when authInfo is nil")
        }
    }
}

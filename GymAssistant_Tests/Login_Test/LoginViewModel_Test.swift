//
//  LoginViewModel_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 19.12.2024.
//

import XCTest
import Combine
@testable import GymAssistant

final class LoginViewModel_Test: XCTestCase {
    var sut: LoginViewModel!
    var mockAuthService: AuthService!
    var mockAuthManager: AuthManager!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        self.mockAuthService = MockAuthService()
        self.mockAuthManager = AuthManager(service: mockAuthService)
        self.cancellables = Set<AnyCancellable>()
        self.sut = LoginViewModel(authManager: mockAuthManager)
    }
    
    override func tearDown() {
        self.sut = nil
        self.mockAuthManager = nil
        self.mockAuthService = nil
        self.cancellables = nil
        super.tearDown()
    }
    
    @MainActor
    func testSignInSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "SignIn should be successful")
        let expectation2 = XCTestExpectation(description: "SignOut should be successful")
        let register = Register.mockRegister()
        mockAuthManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockAuthManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNoThrow(try mockAuthManager.signOut(), "SignOut should not throw error")
        let signIn = SignIn(email: register.email, password: register.password)
        sut.signInModel = signIn
        mockAuthManager.$authInfo
            .dropFirst()
            .sink { authInfo in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        self.sut.signIn()
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNil(sut.alert)
        XCTAssertNotNil(mockAuthManager.authInfo)
        XCTAssertEqual(mockAuthManager.authInfo?.email, signIn.email)
    }
    
    @MainActor
    func testSignInFailure() async {
        // Given
        let expectation = XCTestExpectation(description: "AuthInfo should be fetched")
        let expectation2 = XCTestExpectation(description: "SignUp should be successful")
        let register = Register.mockRegister()
        mockAuthManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockAuthManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNoThrow(try mockAuthManager.signOut(), "SignOut should not throw error")
        let signIn = SignIn(email: register.email, password: UUID().uuidString)
        sut.signInModel = signIn
        sut.$alert
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        self.sut.signIn()
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.subtitle, AppAuthError.wrongPassword.subtitle)
    }
    
    @MainActor
    func testResetPasswordSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "ShowForgotPassword should be toggle")
        let expectation2 = XCTestExpectation(description: "SingUp should be successful")
        let register = Register.mockRegister()
        mockAuthManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockAuthManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNoThrow(try mockAuthManager.signOut(), "SignOut should not throw error")
        sut.showForgotPassword = true
        sut.$showForgotPassword
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        sut.resetPassword(email: register.email)
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNil(sut.alert)
        XCTAssertFalse(sut.showForgotPassword)
    }
    
    @MainActor
    func testResetPasswordFailure() async {
        // Given
        let register = Register.mockRegister()
        let expectation = XCTestExpectation(description: "Alert should be shown up")
        let expectation2 = XCTestExpectation(description: "SignOut should be successful")
        mockAuthManager.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockAuthManager.signUp(register: register)
        } catch {
            XCTFail("SignUp should not throw error")
        }
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNoThrow(try mockAuthManager.signOut(), "SignOut should not throw error")
        sut.showForgotPassword = true
        sut.$alert
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        sut.resetPassword(email: "mock")
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.subtitle, CustomError.customError(title: "Email",
                                                                    subtitle: "Email not found").subtitle)
    }
}

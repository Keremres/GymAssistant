//
//  File.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 19.12.2024.
//

import XCTest
import Combine
@testable import GymAssistant

final class RegisterViewModel_Test: XCTestCase {
    var sut: RegisterViewModel!
    var mockAuthService: AuthService!
    var mockAuthManager: AuthManager!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        self.mockAuthService = MockAuthService()
        self.mockAuthManager = AuthManager(service: mockAuthService)
        self.cancellables = Set<AnyCancellable>()
        self.sut = RegisterViewModel(authManager: mockAuthManager)
    }
    
    override func tearDown() {
        self.sut = nil
        self.mockAuthService = nil
        self.mockAuthManager = nil
        self.cancellables = nil
        super.tearDown()
    }
    
    @MainActor
    func testCreateUserSuccess() async {
        // Given
        let register = Register.mockRegister()
        sut.register = register
        let expectation = XCTestExpectation(description: "Create User")
        mockAuthManager.$authInfo
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        sut.createUser()
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNotNil(mockAuthManager.authInfo)
        XCTAssertEqual(mockAuthManager.authInfo?.email, register.email)
        XCTAssertNil(sut.alert)
    }
    
    @MainActor
    func testCreateUserFailure() async {
        // Given
        let register = Register.mockRegister(email: UUID().uuidString)
        sut.register = register
        let expectation = XCTestExpectation(description: "Create User")
        sut.$alert
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        sut.createUser()
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNil(mockAuthManager.authInfo)
        XCTAssertNotNil(sut.alert)
    }
}

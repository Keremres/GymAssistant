//
//  UserManager_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 6.11.2024.
//

import XCTest
import Combine
@testable import GymAssistant

@MainActor
final class UserManager_Test: XCTestCase {
    
    private var userManager: UserManager!
    private var mockUserService: MockUserService!
    private var mockAuthService: MockAuthService!
    private var mockAuthManager: AuthManager!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        mockUserService = MockUserService()
        mockAuthService = MockAuthService()
        mockAuthManager = AuthManager(service: mockAuthService)
        userManager = UserManager(service: mockUserService, authManager: mockAuthManager)
        let register = Register.mockRegister()
        Task{
            try await mockAuthManager.signUp(register: register)
        }
    }
    
    override func tearDownWithError() throws {
        cancellables.removeAll()
        cancellables = []
        userManager = nil
        mockUserService = nil
        mockAuthService = nil
        mockAuthManager = nil
    }
    
    func test_GetUserInfo_Success() async throws {
        // Given
        let mockUserInfo = UserInfo.userInfoMock()
        mockUserService.mockUserInfo = mockUserInfo
        
        // When
        try await userManager.getUserInfo(userId: mockUserInfo.id)
        
        // Then
        XCTAssertEqual(userManager.userInfo, mockUserInfo)
    }
    
    func test_GetUserInfo_UserNotFound() async throws {
        // Given
        let userId = "nonExistentUserId"
        mockUserService.mockUserInfo = nil // Kullanıcı bilgisi yok.
        
        // When & Then
        do {
            try await userManager.getUserInfo(userId: userId)
            XCTFail("Expected to throw an error but succeeded")
        } catch {
            XCTAssertEqual(error.localizedDescription,
                           CustomError.customError(title: "Error",
                                                   subtitle: "Id mismatch").localizedDescription)
        }
    }
    
    func test_UpdateUserInfo() async throws {
        // Given
        let userInfo = UserInfo.userInfoMock()
        let updatedUserInfo = UserInfo(userInfo: userInfo, title: "Admin")
        mockUserService.mockUserInfo = userInfo
        
        // When
        try await userManager.updateUserInfo(update: updatedUserInfo)
        
        // Then
        XCTAssertEqual(userManager.userInfo, updatedUserInfo)
        XCTAssertEqual(mockUserService.mockUserInfo, updatedUserInfo)
    }
    
    func test_UserProgramUpdate() async throws {
        // Given
        let userInfo = UserInfo.userInfoMock()
        let programId = UUID().uuidString
        mockUserService.mockUserInfo = userInfo
        
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        
        // Listen for authInfo update
        userManager.$userInfo
            .dropFirst()
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // When
        try await userManager.userProgramUpdate(programId: programId)
        
        // Then
        XCTAssertEqual(userManager.userInfo?.programId, programId)
    }
    
    func test_UserProgramDelete() async throws {
        // Given
        let userInfo = UserInfo.userInfoMock(programId: UUID().uuidString)
        mockUserService.mockUserInfo = userInfo
        
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        
        // Listen for authInfo update
        userManager.$userInfo
            .dropFirst()
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // When
        try await userManager.userProgramDelete()
        
        // Then
        XCTAssertEqual(userManager.userInfo?.programId, "")
    }
    
    func test_UserInfoDelete() async throws {
        // Given
        let userInfo = UserInfo.userInfoMock()
        mockUserService.mockUserInfo = userInfo
        
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        
        // Listen for authInfo update
        userManager.$userInfo
            .dropFirst()
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // When
        try await userManager.userInfoDelete()
        
        // Then
        XCTAssertNil(userManager.userInfo)
    }
    
    func test_UpdateUserLogin() async throws {
        // Given
        let userInfo = UserInfo(userInfo: UserInfo.userInfoMock(), lastLoginDate: Date.oneWeekAgo)
        mockUserService.mockUserInfo = userInfo
        
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        
        // Listen for authInfo update
        userManager.$userInfo
            .dropFirst()
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // When
        
        // Then
        XCTAssertNotNil(userManager.userInfo?.lastLoginDate)
        XCTAssertNotEqual(Date.getCurrentWeekInt(date: userManager.userInfo!.lastLoginDate!),
                          Date.getCurrentWeekInt(date: userInfo.lastLoginDate!))
        XCTAssertGreaterThan(Date.getCurrentWeekInt(date: userManager.userInfo!.lastLoginDate!),
                             Date.getCurrentWeekInt(date: userInfo.lastLoginDate!))
    }
}

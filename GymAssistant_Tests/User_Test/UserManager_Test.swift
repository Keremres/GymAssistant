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
    var userManager: UserManager!
    var mockUserService: MockUserService!
    var mockAuthService: MockAuthService!
    var mockAuthManager: AuthManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        self.cancellables = Set<AnyCancellable>()
        self.mockUserService = MockUserService()
        self.mockAuthService = MockAuthService()
        self.mockAuthManager = AuthManager(service: mockAuthService)
        self.userManager = UserManager(service: mockUserService, authManager: mockAuthManager)
        let register = Register.mockRegister()
        Task{
            do{
                try await mockAuthManager.signUp(register: register)
            } catch {
                XCTFail("SignUp should not throw error")
            }
        }
    }
    
    override func tearDown() {
        self.cancellables = nil
        self.userManager = nil
        self.mockUserService = nil
        self.mockAuthService = nil
        self.mockAuthManager = nil
        super.tearDown()
    }
    
    func test_GetUserInfo_Success() async {
        // Given
        let mockUserInfo = UserInfo.userInfoMock()
        mockUserService.mockUserInfo = mockUserInfo
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        userManager.$userInfo
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await userManager.getUserInfo(userId: mockUserInfo.id)
        } catch {
            XCTFail("GetUserInfo should not throw error")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(userManager.userInfo?.id, mockUserInfo.id)
    }
    
    func test_GetUserInfo_UserNotFound() async {
        // Given
        let userId = "nonExistentUserId"
        mockUserService.mockUserInfo = nil
        
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
    
    func test_UpdateUserInfo_Success() async {
        // Given
        let userInfo = UserInfo.userInfoMock()
        let updatedUserInfo = UserInfo(userInfo: userInfo, title: "Admin")
        mockUserService.mockUserInfo = userInfo
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        userManager.$userInfo
            .sink { userInfo in
                if userInfo == updatedUserInfo {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await userManager.updateUserInfo(update: updatedUserInfo)
        } catch {
            XCTFail("UpdateUserInfo should not throw error")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(userManager.userInfo?.id, updatedUserInfo.id)
        XCTAssertEqual(userManager.userInfo?.title, updatedUserInfo.title)
        XCTAssertEqual(mockUserService.mockUserInfo?.id, updatedUserInfo.id)
        XCTAssertEqual(mockUserService.mockUserInfo?.title, updatedUserInfo.title)
    }
    
    func test_UserProgramUpdate_Success() async {
        // Given
        let userInfo = UserInfo.userInfoMock()
        let programId = UUID().uuidString
        mockUserService.mockUserInfo = userInfo
        
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        let expectation2 = XCTestExpectation(description: "Wait for userInfo.programId to be set")
        
        // Listen for authInfo update
        userManager.$userInfo
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
                if userInfo?.programId != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // When
        do{
            try await userManager.userProgramUpdate(programId: programId)
        } catch {
            XCTFail("UserProgramUpdate should not throw error: \(error)")
        }
        
        // Then
        await fulfillment(of: [expectation2], timeout: 1.0)
        XCTAssertEqual(userManager.userInfo?.programId, programId)
    }
    
    func test_UserProgramDelete_Success() async {
        // Given
        let userInfo = UserInfo.userInfoMock(programId: UUID().uuidString)
        mockUserService.mockUserInfo = userInfo
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        userManager.$userInfo
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // When
        do{
            try await userManager.userProgramDelete()
        } catch {
            XCTFail("UserProgramDelete should not throw error: \(error)")
        }
        
        // Then
        XCTAssertEqual(userManager.userInfo?.programId, "")
    }
    
    func test_UserInfoDelete_Success() async {
        // Given
        let userInfo = UserInfo.userInfoMock()
        mockUserService.mockUserInfo = userInfo
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        let expectation2 = XCTestExpectation(description: "Wait for userInfo to be set nil")
        userManager.$userInfo
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await fulfillment(of: [expectation], timeout: 1.0)
        
        userManager.$userInfo
            .sink { userInfo in
                if userInfo == nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await userManager.userInfoDelete()
        } catch {
            XCTFail("UserInfoDelete should not throw error: \(error)")
        }
        
        // Then
        await fulfillment(of: [expectation2], timeout: 1.0)
        XCTAssertNil(userManager.userInfo)
    }
    
    func test_UpdateUserLogin() async {
        // Given
        let userInfo = UserInfo(userInfo: UserInfo.userInfoMock(), lastLoginDate: Date.oneWeekAgo)
        mockUserService.mockUserInfo = userInfo
        let expectation = XCTestExpectation(description: "Wait for userInfo to be set")
        userManager.$userInfo
            .dropFirst()
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
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

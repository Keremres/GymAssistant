//
//  PersonViewModel_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 20.12.2024.
//

import XCTest
import Combine
@testable import GymAssistant

final class PersonViewModel_Test: XCTestCase {
    var sut: PersonViewModel!
    var mockProgramService: MockProgramService!
    var mockProgramManager: ProgramManager!
    var mockAuthService: MockAuthService!
    var mockAuthManager: AuthManager!
    var mockUserService: MockUserService!
    var mockUserManager: UserManager!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        self.mockProgramService = MockProgramService()
        self.mockProgramManager = ProgramManager(service: mockProgramService)
        self.mockAuthService = MockAuthService()
        self.mockAuthManager = AuthManager(service: mockAuthService)
        self.mockUserService = MockUserService()
        self.mockUserManager = UserManager(service: mockUserService, authManager: mockAuthManager)
        self.cancellables = Set<AnyCancellable>()
        self.sut = PersonViewModel(authManager: mockAuthManager,
                              userManager: mockUserManager,
                              programManager: mockProgramManager)
    }
    
    override func tearDown() {
        self.sut = nil
        self.mockProgramService = nil
        self.mockProgramManager = nil
        self.mockAuthService = nil
        self.mockAuthManager = nil
        self.mockUserService = nil
        self.mockUserManager = nil
        self.cancellables = nil
        super.tearDown()
    }
    
    @MainActor
    func testSignOutSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "AuthManager singUp")
        let expectation2 = XCTestExpectation(description: "AuthManager signOut")
        
        mockAuthManager.$authInfo
            .sink { authInfo in
                if authInfo != nil{
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("SingUp should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        
        mockAuthManager.$authInfo
            .dropFirst()
            .sink { authInfo in
                if authInfo == nil{
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.signOut()
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNil(mockAuthManager.authInfo)
        XCTAssertNil(sut.alert)
    }
    
    @MainActor
    func testSignOutFailure() async {
        // Given
        
        //When
        sut.signOut()
        
        //Then
        XCTAssertEqual(sut.alert?.subtitle, CustomError.customError(title: "AuthInfo",
                                                                    subtitle: "AuthInfo not found").subtitle)
    }
    
    @MainActor
    func testProgramOutSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "ProgramManager should update program")
        let expectation2 = XCTestExpectation(description: "UserManager should update user")
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("SignUp should not throw error")
        }
        let program: Program = .baseProgram()
        mockUserService.mockUserInfo = .userInfoMock()
        do{
            try await mockUserManager.updateUserInfo(update: .userInfoMock(programId: program.id))
        } catch {
            XCTFail("UpdateUserInfo should not throw error")
        }
        mockProgramManager.$program
            .sink { program in
                if program != nil{
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockProgramManager.useProgram(userInfo: .userInfoMock(), program: program)
        } catch {
            XCTFail("UseProgram should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        mockUserManager.$userInfo
            .dropFirst()
            .sink { userInfo in
                if userInfo != nil{
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.programOut()
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertEqual(mockUserManager.userInfo?.programId, "")
        XCTAssertNil(mockProgramManager.program)
    }
    
    @MainActor
    func testProgramOutFailure() async {
        // Given
        let expectation = XCTestExpectation(description: "PersonViewModel should alert")
        sut.$alert
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        sut.programOut()
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.subtitle, CustomError.authError(appAuthError: .userNotFound).subtitle)
    }
    
    @MainActor
    func testDeleteAccountSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "UserManager should update user info")
        let expectation2 = XCTestExpectation(description: "AuthManager should delete user")
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("SignUp should not throw error")
        }
        mockUserService.mockUserInfo = .userInfoMock()
        mockUserManager.$userInfo
            .dropFirst()
            .sink { userInfo in
                if userInfo != nil{
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockUserManager.updateUserInfo(update: .userInfoMock())
        } catch {
            XCTFail("UpdateUserInfo should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        mockAuthManager.$authInfo
            .dropFirst()
            .sink { authInfo in
                if authInfo == nil{
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.deleteAccount()
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNil(mockUserManager.userInfo)
        XCTAssertNil(mockAuthManager.authInfo)
        XCTAssertNil(sut.alert)
    }
}

//
//  ProgramHistoryViewModel_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 20.12.2024.
//

import XCTest
import Combine
@testable import GymAssistant

final class ProgramHistoryViewModel_Test: XCTestCase {
    var sut: ProgramHistoryViewModel!
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
        self.sut = ProgramHistoryViewModel(programManager: mockProgramManager,
                                      userManager: mockUserManager)
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
    func testGetProgramHistorySuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "ProgramManager should update program")
        let expectation2 = XCTestExpectation(description: "ProgramHistoryViewModel should fetch program")
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
        sut.alert = nil
        
        sut.$programHistory
            .dropFirst()
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        sut.getProgramHistory()
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertEqual(sut.programHistory.count, 1)
        XCTAssertNil(sut.alert)
    }
    
    @MainActor
    func testProgramDeleteSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "ProgramManager should update program")
        let expectation2 = XCTestExpectation(description: "ProgramService should update program")
        let expectation3 = XCTestExpectation(description: "ProgramHistoryViewModel should update programs")
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
        sut.alert = nil
        
        sut.$programHistory
            .dropFirst()
            .sink { _ in
                expectation3.fulfill()
            }
            .store(in: &cancellables)
        sut.getProgramHistory()
        await fulfillment(of: [expectation3], timeout: 1)
        
        mockUserManager.$userInfo
            .dropFirst()
            .sink { userIfo in
                if userIfo?.programId == ""{
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.programDelete(program: program)
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNotNil(mockUserManager.userInfo)
        XCTAssertEqual(mockUserManager.userInfo?.programId, "")
        XCTAssertNil(mockProgramManager.program)
        XCTAssertEqual(mockProgramService.mockUserProgramHistory, [])
        XCTAssertEqual(sut.programHistory, [])
        XCTAssertNil(sut.alert)
    }
}

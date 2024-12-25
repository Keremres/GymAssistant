//
//  HomeViewModel_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 20.12.2024.
//

import XCTest
import Combine
@testable import GymAssistant

final class HomeViewModel_Test: XCTestCase {
    var sut: HomeViewModel!
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
        self.sut = HomeViewModel(programManager: mockProgramManager, userManager: mockUserManager)
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
    func testGetProgramSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "UserManager update")
        let expectation2 = XCTestExpectation(description: "ProgramManager update")
        
        let mockProgram: Program = .MOCK_PROGRAM
        mockProgramService.mockProgram = mockProgram
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("SingUp should not throw error")
        }
        mockUserService.mockUserInfo = .userInfoMock()
        mockUserManager.$userInfo
            .sink { userInfo in
                if userInfo?.programId == mockProgram.id {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockUserManager.updateUserInfo(update: .userInfoMock(programId: mockProgram.id))
        } catch {
            XCTFail("UserManager update should not throw error")
        }
        
        await fulfillment(of: [expectation], timeout: 1)
        sut.alert = nil
        
        mockProgramManager.$program
            .sink { program in
                if program?.id == mockProgram.id {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.getProgram()
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(mockProgramManager.program?.id, mockProgram.id)
    }
    
    @MainActor
    func testNewWeekSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "UserManager should update user info")
        let expectation2 = XCTestExpectation(description: "ProgramManager should update program")
        let expectation3 = XCTestExpectation(description: "HomeViewModel should update program")
        let day = DayModel.MOCK_DAY
        let week = WeekModel(date: Date.oneWeekAgo,
                             day: day)
        let mockProgram = Program(programName: "Test Program",
                              programClass: "Test Class" ,
                              week: [week])
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("SingUp should not throw error")
        }
        mockUserService.mockUserInfo = .userInfoMock()
        mockUserManager.$userInfo
            .sink { userInfo in
                if userInfo?.programId == mockProgram.id {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockUserManager.updateUserInfo(update: .userInfoMock(programId: mockProgram.id))
        } catch {
            XCTFail("SingUp should not throw error")
        }
        mockProgramService.mockProgram = mockProgram
        await fulfillment(of: [expectation], timeout: 1)
        sut.alert = nil
        
        mockProgramManager.$program
            .sink { program in
                if program?.id == mockProgram.id {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        sut.getProgram()
        await fulfillment(of: [expectation2], timeout: 1)
        
        mockProgramManager.$program
            .sink { program in
                if program?.week.count == 2 {
                    expectation3.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.newWeek()
        
        //Then
        await fulfillment(of: [expectation3], timeout: 1)
        XCTAssertEqual(mockProgramManager.program?.week.count, 2)
        XCTAssertNil(sut.alert)
    }
}
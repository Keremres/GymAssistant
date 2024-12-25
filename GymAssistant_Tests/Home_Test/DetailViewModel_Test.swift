//
//  DetailViewModel_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 20.12.2024.
//

import XCTest
import Combine
@testable import GymAssistant

final class DetailViewModel_Test: XCTestCase {
    var sut: DetailViewModel!
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
        self.sut = DetailViewModel(programManager: mockProgramManager, userManager: mockUserManager)
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
    func testSaveDaySuccess() async {
        // Given
        let mockProgram: Program = .mockProgram()
        var givenMockDayModel: DayModel = mockProgram.week[0].day[0]
        givenMockDayModel.exercises[0].weight += 10
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("SingUp should not throw error")
        }
        mockUserService.mockUserInfo = .userInfoMock()
        do{
            try await mockUserManager.updateUserInfo(update: .userInfoMock(programId: mockProgram.id))
        } catch {
            XCTFail("UpdateUserInfo should not throw error")
        }
        mockProgramService.mockProgram = mockProgram
        let expectation = XCTestExpectation(description: "ProgramManager.getProgram")
        
        mockProgramManager.$program
            .sink { program in
                if program?.id == mockProgram.id {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockProgramManager.getProgram(userInfo: .userInfoMock(programId: mockProgram.id))
        } catch {
            XCTFail("GetProgram should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        let expectation2 = XCTestExpectation(description: "DetailsViewModel.saveDay")
        
        mockProgramManager.$program
            .sink { program in
                if program?.week[0].day[0].exercises[0].weight == givenMockDayModel.exercises[0].weight {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.saveDay(dayModel: givenMockDayModel)
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertEqual(mockProgramManager.program?.week[0].day[0].exercises[0].weight, givenMockDayModel.exercises[0].weight)
    }
    
    @MainActor
    func testSaveDayFailure() async {
        // Given
        let mockProgram: Program = .mockProgram()
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("SignUp should not throw error")
        }
        mockUserService.mockUserInfo = .userInfoMock()
        do{
            try await mockUserManager.updateUserInfo(update: .userInfoMock(programId: mockProgram.id))
        } catch {
            XCTFail("UpdateUserInfo should not throw error")
        }
        mockProgramService.mockProgram = mockProgram
        let expectation = XCTestExpectation(description: "ProgramManager should fetch program")
        
        mockProgramManager.$program
            .sink { program in
                if program?.id == mockProgram.id {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        try! await mockProgramManager.getProgram(userInfo: .userInfoMock(programId: mockProgram.id))
        await fulfillment(of: [expectation], timeout: 1)
        sut.alert = nil
        
        let expectation2 = XCTestExpectation(description: "DetailViewModel should show alert")
        
        sut.$alert
            .sink { alert in
                if alert != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.saveDay(dayModel: .baseDay())
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNotNil(sut.alert)
    }
}

//
//  CreateViewModel_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 19.12.2024.
//

import XCTest
import Combine
@testable import GymAssistant

final class CreateViewModel_Test: XCTestCase {
    var sut: CreateViewModel!
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
        self.sut = CreateViewModel(programManager: mockProgramManager, userManager: mockUserManager)
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
    func testAddDaySuccess() {
        // Given
        
        //When
        sut.addDay()
        //Then
        XCTAssertEqual(sut.program.week[0].day.count, 2)
    }
    
    @MainActor
    func testAddDayWithEmptyDaySuccess() {
        // Given
        let program: Program = .mockProgram(week: [])
        sut.program = program
        
        //When
        sut.addDay()
        
        //Then
        XCTAssertEqual(sut.program.week.count, 1)
    }
    
    @MainActor
    func testAddExercisesSuccess() {
        // Given
        let program = sut.program
        
        //When
        sut.addExercises(dayModel: program.week[0].day[0])
        
        //Then
        XCTAssertEqual(sut.program.week[0].day[0].exercises.count, 2)
    }
    
    @MainActor
    func testAddExercisesWithEmptyExercisesSuccess() {
        // Given
        let dayModel = DayModel.MOCK_DAY[1]
        
        //When
        sut.addExercises(dayModel: dayModel)
        
        //Then
        XCTAssertEqual(sut.program.week[0].day.count, 2)
    }
    
    @MainActor
    func testDeleteDaySuccess() {
        // Given
        let program = sut.program
        
        //When
        sut.deleteDay(id: program.week[0].day[0].id)
        
        //Then
        XCTAssertEqual(sut.program.week[0].day.count, 0)
    }
    
    @MainActor
    func testDeleteExerciseSuccess() {
        // Given
        let program = sut.program
        
        //When
        sut.deleteExercise(idExercise: program.week[0].day[0].exercises[0].id, idDayModel: program.week[0].day[0].id)
        
        //Then
        XCTAssertEqual(sut.program.week[0].day[0].exercises.count, 0)
    }
    
    @MainActor
    func testCreateSuccess() async {
        // Given
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("Error signing up")
        }
        mockUserService.mockUserInfo = .userInfoMock()
        let expectation = XCTestExpectation(description: "UserInfo should be fetched")
        let expectation2 = XCTestExpectation(description: "Program should be created")
        let expectation3 = XCTestExpectation(description: "UserInfo.programId should be published")
        
        mockUserManager.$userInfo
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        await fulfillment(of: [expectation], timeout: 1)
        
        mockProgramManager.$program
            .dropFirst()
            .sink { program in
                if program != nil{
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        mockUserManager.$userInfo
            .dropFirst()
            .sink { userInfo in
                if userInfo?.programId != nil{
                    expectation3.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.create()
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        await fulfillment(of: [expectation3], timeout: 1)
        XCTAssertNotNil(sut.program)
        XCTAssertNotNil(mockUserManager.userInfo?.programId)
        XCTAssertEqual(sut.program.id, mockUserManager.userInfo?.programId)
    }
    
    @MainActor
    func testCreateFailure() async {
        // Given
        let expectation = XCTestExpectation(description: "Alert should be shown")
        sut.$alert
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        sut.create()
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.subtitle, CustomError.authError(appAuthError: .userNotFound).subtitle)
    }
    
    @MainActor
    func testPublishProgramSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "Program should be published")
        mockProgramService.$mockPublishedPrograms
            .sink { programs in
                if programs.count > 0{
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.publishProgram()
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNotNil(mockProgramService.mockPublishedPrograms)
    }
}

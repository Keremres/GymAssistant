//
//  ProgramManager_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 5.11.2024.
//

import XCTest
@testable import GymAssistant

@MainActor
final class ProgramManager_Test: XCTestCase {
    
    private var programManager: ProgramManager!
    private var mockService: MockProgramService!
    
    override func setUpWithError() throws {
        mockService = MockProgramService()
        programManager = ProgramManager(service: mockService)
    }
    
    override func tearDownWithError() throws {
        programManager = nil
        mockService = nil
    }
    
    func test_UseProgram() async throws {
        // Given
        let userInfo = UserInfo.userInfoMock()
        let program = Program.MOCK_PROGRAM
        
        // When
        try await programManager.useProgram(userInfo: userInfo, program: program)
        
        // Then
        XCTAssertEqual(programManager.program?.id, program.id)
        XCTAssertEqual(mockService.mockUserProgramHistory.first?.id, program.id)
    }
    
    func test_PublishProgram() async throws {
        // Given
        let program = Program.MOCK_PROGRAM
        
        // When
        try await programManager.publishProgram(program: program)
        
        // Then
        XCTAssertEqual(mockService.mockPublishedPrograms.first?.id, program.id)
    }
    
    func test_GetProgram() async throws {
        // Given
        let program = Program.MOCK_PROGRAM
        let userInfo = UserInfo.userInfoMock(programId: program.id)
        mockService.mockProgram = program
        
        // When
        try await programManager.getProgram(userInfo: userInfo)
        
        // Then
        XCTAssertEqual(programManager.program?.id, program.id)
    }
    
    func test_GetPrograms() async throws {
        // Given
        let program1 = Program.baseProgram()
        let program2 = Program.baseProgram()
        mockService.mockPublishedPrograms = [program1, program2]
        
        // When
        let programs = try await programManager.getPrograms()
        
        // Then
        XCTAssertEqual(programs.count, 2)
        XCTAssertEqual(programs.first?.id, program1.id)
        XCTAssertEqual(programs.last?.id, program2.id)
    }
    
    func test_GetProgramHistory() async throws {
        // Given
        let program1 = Program.baseProgram()
        let program2 = Program.baseProgram()
        let userInfo = UserInfo.userInfoMock(programId: program2.id)
        mockService.mockUserProgramHistory = [program1, program2]
        
        // When
        let history = try await programManager.getProgramHistory(userInfo: userInfo)
        
        // Then
        XCTAssertEqual(history.count, 2)
        XCTAssertEqual(history.last?.id, program2.id)
    }
    
    func test_DeleteProgramHistory() async throws {
        // Given
        let program = Program.MOCK_PROGRAM
        let userInfo = UserInfo.userInfoMock(programId: program.id)
        mockService.mockUserProgramHistory = [program]
        
        // When
        try await programManager.deleteProgramHistory(userInfo: userInfo, programId: program.id)
        
        // Then
        XCTAssertTrue(mockService.mockUserProgramHistory.isEmpty)
    }
    
    func test_NewWeek() async throws {
        // Given
        let day = DayModel.MOCK_DAY
        let week = WeekModel(date: Date.oneWeekAgo,
                             day: day)
        let program = Program(programName: "Test Program",
                              programClass: "Test Class" ,
                              week: [week])
        let userInfo = UserInfo.userInfoMock(programId: program.id)
        programManager.program = program
        
        // When
        try await programManager.newWeek(userInfo: userInfo)
        
        // Then
        XCTAssertEqual(programManager.program?.week.count, 2)
    }
    
    func test_SaveDay() async throws {
        // Given
        let exercise = Exercises(exercise: "Squat",
                                 againStart: 6,
                                 again: 6,
                                 againEnd: 8,
                                 weight: 50,
                                 date: Date.oneWeekAgo)
        let givenExercise = Exercises(id: exercise.id,
                                      exercise: exercise.exercise,
                                      againStart: exercise.againStart,
                                      again: exercise.again + 1,
                                      againEnd: exercise.againEnd,
                                      weight: exercise.weight + 1.25,
                                      date: exercise.date)
        let day = DayModel(day: "Monday",
                           exercises: [exercise])
        let givenDay = DayModel(id: day.id,
                                day: day.day,
                                exercises: [givenExercise])
        let week = WeekModel(day: [day])
        let program = Program(programName: "Test Program",
                              programClass: "Test Class",
                              week: [week])
        let userInfo = UserInfo.userInfoMock(programId: program.id)
        programManager.program = program
        
        // When
        try await programManager.saveDay(userInfo: userInfo, dayModel: givenDay)
        
        // Then
        XCTAssertEqual(Date.getCurrentWeekInt(date: programManager.program!.week[0].day[0].exercises[0].date), Date.getCurrentWeekInt(date: Date()))
        XCTAssertEqual(programManager.program?.week[0].day[0].exercises[0].again, givenDay.exercises[0].again)
        XCTAssertEqual(programManager.program?.week[0].day[0].exercises[0].weight, givenDay.exercises[0].weight)
    }
    
    func test_ChartCalculator() {
        // Given
        let exercise = Exercises(exercise: "Squat",
                                 againStart: 6,
                                 again: 6,
                                 againEnd: 8,
                                 weight: 50,
                                 date: Date())
        let day = DayModel(day: "Monday",
                           exercises: [exercise])
        let week = WeekModel(day: [day])
        let program = Program(programName: "Test Program",
                              programClass: "Test Class",
                              week: [week])
        programManager.program = program
        
        // When
        let chartData = programManager.chartCalculator(exerciseId: exercise.id)
        
        // Then
        XCTAssertEqual(chartData.count, 1)
        XCTAssertEqual(chartData.first?.value, 50)
    }
    
    func test_ProgramClear() {
        // Given
        let program = Program.MOCK_PROGRAM
        programManager.program = program
        
        // When
        programManager.programClear()
        
        // Then
        XCTAssertNil(programManager.program)
    }
}

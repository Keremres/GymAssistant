//
//  ProgramManager_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 5.11.2024.
//

import XCTest
import Combine
@testable import GymAssistant

@MainActor
final class ProgramManager_Test: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var programManager: ProgramManager!
    var mockService: MockProgramService!
    
    override func setUp() {
        super.setUp()
        self.cancellables = Set<AnyCancellable>()
        self.mockService = MockProgramService()
        self.programManager = ProgramManager(service: mockService)
    }
    
    override func tearDown() {
        self.cancellables = nil
        self.programManager = nil
        self.mockService = nil
        super.tearDown()
    }
    
    func test_UseProgram() async {
        // Given
        let userInfo = UserInfo.userInfoMock()
        let program = Program.MOCK_PROGRAM
        let expectation = XCTestExpectation(description: "Wait for program to be set")
        programManager.$program
            .sink { program in
                if program != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await programManager.useProgram(userInfo: userInfo, program: program)
        } catch {
            XCTFail("UseProgram should not throw error: \(error)")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(programManager.program?.id, program.id)
        XCTAssertEqual(mockService.mockUserProgramHistory.first?.id, program.id)
    }
    
    func test_PublishProgram() async {
        // Given
        let program = Program.MOCK_PROGRAM
        let expectation = XCTestExpectation(description: "Wait for program to be published")
        mockService.$mockPublishedPrograms
            .sink { publishedPrograms in
                if publishedPrograms.contains(where: { $0.id == program.id }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await programManager.publishProgram(program: program)
        } catch {
            XCTFail("PublishProgram should not throw error: \(error)")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(mockService.mockPublishedPrograms.first?.id, program.id)
    }
    
    func test_GetProgram() async {
        // Given
        let program = Program.MOCK_PROGRAM
        let userInfo = UserInfo.userInfoMock(programId: program.id)
        mockService.mockProgram = program
        let expectation = XCTestExpectation(description: "Wait for program to be fetched")
        programManager.$program
            .sink { fetchedProgram in
                if fetchedProgram?.id == program.id {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        do{
            try await programManager.getProgram(userInfo: userInfo)
        } catch {
            XCTFail("GetProgram should not throw error: \(error)")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(programManager.program?.id, program.id)
    }
    
    func test_GetPrograms() async {
        // Given
        let program1 = Program.baseProgram()
        let program2 = Program.baseProgram()
        mockService.mockPublishedPrograms = [program1, program2]
        
        // When & Then
        do{
            let programs = try await programManager.getPrograms()
            XCTAssertEqual(programs.count, 2)
            XCTAssertEqual(programs.first?.id, program1.id)
            XCTAssertEqual(programs.last?.id, program2.id)
        } catch {
            XCTFail("GetPrograms should not throw error: \(error)")
        }
    }
    
    func test_GetProgramHistory() async {
        // Given
        let program1 = Program.baseProgram()
        let program2 = Program.baseProgram()
        let userInfo = UserInfo.userInfoMock(programId: program2.id)
        mockService.mockUserProgramHistory = [program1, program2]
        
        // When & Then
        do{
            let history = try await programManager.getProgramHistory(userInfo: userInfo)
            XCTAssertEqual(history.count, 2)
            XCTAssertEqual(history.last?.id, program2.id)
        } catch {
            XCTFail("GetProgramHistory should not throw error: \(error)")
        }
    }
    
    func test_DeleteProgramHistory() async {
        // Given
        let program = Program.MOCK_PROGRAM
        let userInfo = UserInfo.userInfoMock(programId: program.id)
        mockService.mockUserProgramHistory = [program]
        
        // When
        do{
            try await programManager.deleteProgramHistory(userInfo: userInfo, programId: program.id)
        } catch {
            XCTFail("DeleteProgramHistory should not throw error: \(error)")
        }
        
        // Then
        XCTAssertTrue(mockService.mockUserProgramHistory.isEmpty)
    }
    
    func test_NewWeek() async {
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
        do{
            try await programManager.newWeek(userInfo: userInfo)
        } catch {
            XCTFail("NewWeek should not throw error: \(error)")
        }
        
        // Then
        XCTAssertEqual(programManager.program?.week.count, 2)
    }
    
    func test_SaveDay() async {
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
        do{
            try await programManager.saveDay(userInfo: userInfo, dayModel: givenDay)
        } catch {
            XCTFail("SaveDay should not throw error: \(error)")
        }
        
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

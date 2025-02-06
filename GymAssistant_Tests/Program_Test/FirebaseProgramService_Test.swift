//
//  FirebaseProgramService_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 13.01.2025.
//

import XCTest
import Combine
import Firebase
@testable import GymAssistant

final class FirebaseProgramService_Test: XCTestCase {
    var sut: FirebaseProgramService!
    var firebaseAuthService: FirebaseAuthService!
    var userCollection: CollectionReference!
    var programCollection: CollectionReference!
    var cancellables: Set<AnyCancellable>!
    var task: Task<Void, Never>!
    @Published var program: Program?
    @Published var authInfo: AuthInfo?
    
    override func setUp() {
        super.setUp()
        self.cancellables = Set<AnyCancellable>()
        self.userCollection = Firestore.firestore().collection(FirebasePath.test).document(FirebasePath.users).collection(FirebasePath.users)
        self.programCollection = Firestore.firestore().collection(FirebasePath.test).document(FirebasePath.programs).collection(FirebasePath.programs)
        self.sut = FirebaseProgramService(userCollection: userCollection, programCollection: programCollection)
        self.firebaseAuthService = FirebaseAuthService(userCollection: userCollection)
        self.sinkAuthInfo()
    }

    override func tearDown() {
        self.cancellables = nil
        self.task.cancel()
        self.task = nil
        self.userCollection = nil
        self.programCollection = nil
        self.sut = nil
        self.firebaseAuthService = nil
        self.program = nil
        self.authInfo = nil
        super.tearDown()
    }
    
    func testUseProgram() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        let userInfo: GymAssistant.UserInfo = .userInfoMock()
        let newProgram: Program = .mockProgram(id: "0DF2C3C6-319F-4F88-824A-BC4DD32A403E", week: [WeekModel(date: Date.oneWeekAgo, day: [.baseDay()])])
        
        //When
        do {
            try await sut.useProgram(userInfo: userInfo, program: newProgram)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
//        logout()
    }
    
    func testPublishProgram() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        let program: Program = .mockProgram(id: "A223D9F9-6CF7-4FD3-8532-7861B025073E", programName: "Test", programClass: "TestClass")
        
        //When
        do {
            try await sut.publishProgram(program: program)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
//        logout()
    }
    
    func testGetProgram() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        let expectation2 = XCTestExpectation(description: "Program should update")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        let userInfo: GymAssistant.UserInfo = .userInfoMock(programId: "0DF2C3C6-319F-4F88-824A-BC4DD32A403E")
        self.$program
            .sink { program in
                if program != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        do {
            self.program = try await sut.getProgram(userInfo: userInfo)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertEqual(program?.id, userInfo.programId)
//        logout()
    }
    
    func testGetPrograms() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        var programs: [Program] = []
        
        //When
        do {
            programs = try await sut.getPrograms()
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        XCTAssertEqual(programs.count, 1)
        XCTAssertEqual(programs.first?.programName, "Test")
        XCTAssertEqual(programs.first?.programClass, "TestClass")
//        logout()
    }
    
    func testGetProgramHistory() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        let userInfo: GymAssistant.UserInfo = .userInfoMock()
        var programs: [Program] = []
        
        //When
        do {
            programs = try await sut.getProgramHistory(userInfo: userInfo)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        XCTAssertEqual(programs.count, 1)
        XCTAssertEqual(programs.first?.programName, Program.mockProgram().programName)
        XCTAssertEqual(programs.first?.programClass, Program.mockProgram().programClass)
//        logout()
    }
    
    func testNewWeek() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        let expectation2 = XCTestExpectation(description: "Program should update")
        let expectation3 = XCTestExpectation(description: "New week should update")
        
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        let userInfo: GymAssistant.UserInfo = .userInfoMock(programId: "0DF2C3C6-319F-4F88-824A-BC4DD32A403E")
        self.$program
            .sink { program in
                if program != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        do {
            self.program = try await sut.getProgram(userInfo: userInfo)
        } catch {
            XCTFail("Error: \(error)")
        }
        await fulfillment(of: [expectation2], timeout: 1)
        guard let program = self.program else {
            XCTFail("Program is nil")
            return
        }
        self.$program
            .dropFirst()
            .sink { program in
                expectation3.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        do {
            self.program = try await sut.newWeek(userInfo: userInfo, program: program)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation3], timeout: 1)
        XCTAssertEqual(self.program?.week.count, 2)
//        logout()
    }
    
    func testSaveDay() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        let expectation2 = XCTestExpectation(description: "Program should update")
        let expectation3 = XCTestExpectation(description: "New week should update")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        let userInfo: GymAssistant.UserInfo = .userInfoMock(programId: "0DF2C3C6-319F-4F88-824A-BC4DD32A403E")
        self.$program
            .sink { program in
                if program != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        do {
            self.program = try await sut.getProgram(userInfo: userInfo)
        } catch {
            XCTFail("Error: \(error)")
        }
        await fulfillment(of: [expectation2], timeout: 1)
        guard let program = self.program else {
            XCTFail("No program found")
            return
        }
        guard var dayModel = program.week.last?.day.first else {
            XCTFail("No day found")
            return
        }
        dayModel.exercises[0].weight += 10
        
        self.$program
            .dropFirst()
            .sink { program in
                expectation3.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        do {
            self.program = try await sut.saveDay(userInfo: userInfo, dayModel: dayModel, program: program)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation3], timeout: 1)
        guard let program = self.program else {
            XCTFail("No program found")
            return
        }
        XCTAssertEqual(program.week.last?.day.first?.exercises.first?.weight, dayModel.exercises[0].weight)
//        logout()
    }
    
    func testChartCalculator() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        let expectation2 = XCTestExpectation(description: "Get program should update program")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        self.$program
            .sink { program in
                if program != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        do {
            self.program = try await sut.getProgram(userInfo: .userInfoMock(programId: "0DF2C3C6-319F-4F88-824A-BC4DD32A403E"))
        } catch {
            XCTFail("Error fetching program : \(error)")
        }
        await fulfillment(of: [expectation2], timeout: 1)
        guard let program = self.program else {
            XCTFail("No program found")
            return
        }
        guard let exerciseId = program.week.last?.day.first?.exercises[0].id else {
            XCTFail("Exercise id not found")
            return
        }
        var chartData: [ChartModel] = []
        
        //When
        chartData = sut.chartCalculator(exerciseId: exerciseId, program: program)
        
        //Then
        XCTAssertNotNil(chartData)
        XCTAssertEqual(chartData.count, 1)
        XCTAssertEqual(chartData.last?.value, 0)
//        logout()
    }
    
    func testDeleteUserProgramHistory() async {
        //Given
        let expectation = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        let userInfo: GymAssistant.UserInfo = .userInfoMock(programId: "A223D9F9-6CF7-4FD3-8532-7861B025073E")
        
        //When
        do {
            try await sut.deleteUserProgramHistory(userInfo: userInfo, programId: "A223D9F9-6CF7-4FD3-8532-7861B025073E")
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
//        logout()
    }
    
    private func login() async {
        if firebaseAuthService.getAuthenticatedUser() == nil{
            let singIn: SignIn = .init(email: Register.mockRegister().email, password: Register.mockRegister().password)
            do {
                try await firebaseAuthService.signIn(signIn: singIn)
            } catch {
                XCTFail("Error signIn : \(error)")
            }
        }
    }
    
    private func logout() {
        do {
            try firebaseAuthService.signOut()
        } catch {
            XCTFail("Error signOut : \(error)")
        }
    }
    
    private func sinkAuthInfo() {
        self.task = Task { @MainActor in
            for await authInfo in firebaseAuthService.addAuthenticatedUserListener() {
                self.authInfo = authInfo
            }
        }
    }
}

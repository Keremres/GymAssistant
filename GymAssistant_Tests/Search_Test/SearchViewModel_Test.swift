//
//  SearchViewModel_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 20.12.2024.
//

import XCTest
import Combine
@testable import GymAssistant

final class SearchViewModel_Test: XCTestCase {
    var sut: SearchViewModel!
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
        self.sut = SearchViewModel(programManager: mockProgramManager,
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
    func testGetAllProgramsSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "Programs published")
        let expectation2 = XCTestExpectation(description: "Programs fetched")
        let mockProgram: Program = .MOCK_PROGRAM
        let mockBaseProgram: Program = .baseProgram()
        do{
            try await mockProgramManager.publishProgram(program: mockProgram)
        } catch {
            XCTFail("PublishProgram should not throw error")
        }
        mockProgramService.$mockPublishedPrograms
            .dropFirst()
            .sink { programs in
                if programs.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockProgramManager.publishProgram(program: mockBaseProgram)
        } catch {
            XCTFail("PublishProgram should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        sut.alert = nil
        
        sut.$programs
            .sink { programs in
                if programs.count == 2 {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.getAllPrograms()
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertEqual(sut.programs.count, 2)
        XCTAssertEqual(sut.programs.first, mockProgram)
        XCTAssertEqual(sut.programs.last, mockBaseProgram)
        XCTAssertNil(sut.alert)
    }
    
    @MainActor
    func testUseProgramSuccess() async {
        // Given
        let expectation = XCTestExpectation(description: "Programs published")
        let expectation2 = XCTestExpectation(description: "Program fetched")
        let expectation3 = XCTestExpectation(description: "Program used")
        do{
            try await mockAuthManager.signUp(register: .mockRegister())
        } catch {
            XCTFail("SingUp should not throw error")
        }
        mockUserService.mockUserInfo = .userInfoMock()
        do{
            try await mockUserManager.updateUserInfo(update: .userInfoMock())
        } catch {
            XCTFail("SingUp should not throw error")
        }
        let mockProgram: Program = .MOCK_PROGRAM
        mockProgramService.$mockPublishedPrograms
            .sink { programs in
                if programs.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        do{
            try await mockProgramManager.publishProgram(program: mockProgram)
        } catch {
            XCTFail("SingUp should not throw error")
        }
        await fulfillment(of: [expectation], timeout: 1)
        sut.alert = nil
        
        sut.$programs
            .sink { programs in
                if programs.count == 1 {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        sut.getAllPrograms()
        await fulfillment(of: [expectation2], timeout: 1)
        
        mockUserManager.$userInfo
            .sink { userInfo in
                if userInfo?.programId == mockProgram.id {
                    expectation3.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        sut.useProgram(program: sut.programs[0])
        
        //Then
        await fulfillment(of: [expectation3], timeout: 1)
        XCTAssertNotNil(mockProgramManager.program)
        XCTAssertEqual(mockProgramManager.program?.id, mockProgram.id)
        XCTAssertNil(sut.alert)
    }
}

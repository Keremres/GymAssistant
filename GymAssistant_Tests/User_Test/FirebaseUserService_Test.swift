//
//  FirebaseUserService_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 13.01.2025.
//

import XCTest
import Combine
import Firebase
@testable import GymAssistant

final class FirebaseUserService_Test: XCTestCase {
    var sut: FirebaseUserService!
    var firebaseAuthService: FirebaseAuthService!
    var userCollection: CollectionReference!
    var cancellables: Set<AnyCancellable>!
    var task: Task<Void, Never>!
    @Published var userInfo: GymAssistant.UserInfo?
    @Published var authInfo: AuthInfo?
    
    override func setUp() {
        super.setUp()
        self.cancellables = Set<AnyCancellable>()
        self.userCollection = Firestore.firestore().collection(FirebasePath.test).document(FirebasePath.users).collection(FirebasePath.users)
        self.sut = FirebaseUserService(userCollection: userCollection)
        self.firebaseAuthService = FirebaseAuthService(userCollection: userCollection)
        self.sinkAuthInfo()
    }
    
    override func tearDown() {
        self.userCollection = nil
        self.cancellables = nil
        self.sut = nil
        self.task.cancel()
        self.task = nil
        self.authInfo = nil
        self.userInfo = nil
        self.firebaseAuthService = nil
        super.tearDown()
    }
    
    func testGetUserInfo() async {
        //Given
        let expectation = XCTestExpectation(description: "GetUserInfo should update userInfo")
        let expectation2 = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation2], timeout: 1)
        let userInfoMock: GymAssistant.UserInfo = .userInfoMock(id: "phfGQoIqJrdChUr8Sp0ZCAhZ3YO2")
        self.$userInfo
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        do {
            self.userInfo = try await sut.getUserInfo(userId: userInfoMock.id)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(userInfo?.email, userInfoMock.email)
        XCTAssertEqual(userInfo?.id, userInfoMock.id)
//        logout()
    }
    
    func testUpdateUser() async {
        //Given
        let expectation2 = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation2], timeout: 1)
        let newUserInfoMock: GymAssistant.UserInfo = .userInfoMock(id: "phfGQoIqJrdChUr8Sp0ZCAhZ3YO2", lastLoginDate: Date())
        let expectation = XCTestExpectation(description: "UpdateUser should update userInfo")
        self.$userInfo
            .sink { userInfo in
                if userInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        do {
            try await sut.updateUser(userInfo: newUserInfoMock)
            self.userInfo = try await sut.getUserInfo(userId: newUserInfoMock.id)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(userInfo?.lastLoginDate?.description, newUserInfoMock.lastLoginDate?.description)
//        logout()
    }
    
    func testUpdateUserLogin() async {
        //Given
        let expectation2 = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation2], timeout: 1)
        let userInfo: GymAssistant.UserInfo = .userInfoMock(id: "phfGQoIqJrdChUr8Sp0ZCAhZ3YO2")
        let expectation = XCTestExpectation(description: "UpdateUserLogin should update userInfo")
        
        //When
        do {
            self.userInfo = try await sut.updateUserLogin(userInfo: userInfo)
            expectation.fulfill()
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNotNil(self.userInfo?.lastLoginDate)
//        logout()
    }
    
    func testUserProgramUpdate() async {
        //Given
        let expectation2 = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation2], timeout: 1)
        let userInfo = GymAssistant.UserInfo.userInfoMock(id: "phfGQoIqJrdChUr8Sp0ZCAhZ3YO2")
        let programId: Program.ID = UUID().uuidString
        let expectation = XCTestExpectation(description: "UserProgramUpdate should update userInfo")
        
        //When
        do {
            self.userInfo = try await sut.userProgramUpdate(userInfo: userInfo, programId: programId)
            expectation.fulfill()
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(self.userInfo?.programId, programId)
//        logout()
    }
    
    func testUserProgramDelete() async {
        //Given
        let expectation2 = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation2], timeout: 1)
        let userInfo: GymAssistant.UserInfo = .userInfoMock(id: "phfGQoIqJrdChUr8Sp0ZCAhZ3YO2")
        let expectation = XCTestExpectation(description: "UserProgramDelete should delete programId")
        
        //When
        do {
            self.userInfo = try await sut.userProgramDelete(userInfo: userInfo)
            expectation.fulfill()
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(self.userInfo?.programId, "")
//        logout()
    }
    
    func testUserInfoDelete() async {
        //Given
        let expectation2 = XCTestExpectation(description: "Login should update authInfo")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation2], timeout: 1)
        
        let userInfo: GymAssistant.UserInfo = .userInfoMock(id: UUID().uuidString)
        do {
            try await userCollection.setDocument(document: userInfo)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //When
        do {
            try await sut.userInfoDelete(userInfoId: userInfo.id)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        //Then
        do {
            _ = try await sut.getUserInfo(userId: userInfo.id)
        } catch {
            XCTAssertEqual(error as? AppAuthError, AppAuthError.userNotFound)
        }
//        logout()
    }
    
    private func login() async {
        if firebaseAuthService.getAuthenticatedUser() == nil {
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

//
//  FirebaseAuthService_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 13.01.2025.
//

import XCTest
import Combine
import Firebase
@testable import GymAssistant

final class FirebaseAuthService_Test: XCTestCase {
    var sut: FirebaseAuthService!
    var userCollection: CollectionReference!
    var cancellables: Set<AnyCancellable>!
    var task: Task<Void, Never>!
    let register: Register = .mockRegister()
    @Published var authInfo: AuthInfo?
    
    override func setUp() {
        super.setUp()
        self.cancellables = Set<AnyCancellable>()
        self.userCollection = Firestore.firestore().collection(FirebasePath.test).document(FirebasePath.users).collection(FirebasePath.users)
        self.sut = FirebaseAuthService(userCollection: userCollection)
        sinkAuthInfo()
    }
    
    override func tearDown() {
        self.task.cancel()
        self.task = nil
        self.authInfo = nil
        self.sut = nil
        self.userCollection = nil
        self.cancellables = nil
        super.tearDown()
    }
    
    func testSingUpSuccess() async {
        //Given
        let register: Register = .mockRegister(email: "mock@mock.com", password: "123456", verifyPassword: "123456", firstName: "TestFirstName", lastName: "TestLastName")
        let expectation = XCTestExpectation(description: "SingUp wait for success")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        do {
            try await sut.singUp(register: register)
        } catch {
            XCTFail("Error \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(register.email, authInfo?.email)
        await delateAccount()
    }
    
    func testGetAuthenticatedUserSuccess() async {
        //Given
        let expectation = XCTestExpectation(description: "Wait for authInfo to be set")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        
        //When
        let getAuthInfo = sut.getAuthenticatedUser()
        
        //Then
        XCTAssertEqual(getAuthInfo?.email, register.email)
        logout()
    }
    
    func testAddAuthenticatedUserListenerSuccess() async {
        //Given
        let expectation = XCTestExpectation(description: "AddAuthenticatedUserListener wait for success")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        
        //When
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(authInfo?.email, Register.mockRegister().email)
        logout()
    }
    
    func testSignInSuccess() async {
        //Given
        let singIn = SignIn(email: register.email, password: register.password)
        let expectation = XCTestExpectation(description: "SingIn wait for success")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        do {
            try await sut.signIn(signIn: singIn)
        } catch {
            XCTFail("SingIn failed with error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(authInfo?.email, singIn.email)
        logout()
    }
    
    func testSignOutSuccess() async {
        //Given
        let expectation = XCTestExpectation(description: "SignIn wait for success")
        let expectation2 = XCTestExpectation(description: "SignOut wait for success")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        await login()
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertNotNil(authInfo, "Should be authenticated")
        
        self.$authInfo
            .sink { authInfo in
                if authInfo == nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        do {
            try sut.signOut()
        } catch {
            XCTFail("SingOut failed with error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertEqual(authInfo, nil)
    }
    
    func testResetPasswordSuccess() async {
        //Given
        
        
        //When & Then
        do {
            try await sut.resetPassword(email: register.email)
            XCTAssertTrue(true)
        } catch {
            XCTFail("ResetPassword failed with error: \(error)")
        }
    }
    
    func testDeleteAccountSuccess() async {
        //Given
        let expectation = XCTestExpectation(description: "DeleteAccount should be successful")
        let expectation2 = XCTestExpectation(description: "SignUp should be successful")
        self.$authInfo
            .sink { authInfo in
                if authInfo != nil {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        await createAccount()
        await fulfillment(of: [expectation2], timeout: 1)
        XCTAssertNotNil(authInfo)
        self.$authInfo
            .sink { authInfo in
                if authInfo == nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        //When
        do {
            try await sut.deleteAccount()
        } catch {
            XCTFail("DeleteAccount failed with error: \(error)")
        }
        
        //Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(authInfo, nil)
    }
    
    private func sinkAuthInfo() {
        self.task = Task { @MainActor in
            for await authInfo in sut.addAuthenticatedUserListener() {
                self.authInfo = authInfo
            }
        }
    }
    
    private func login() async {
        let signIn: SignIn = .init(email: register.email, password: register.password)
        do {
            try await sut.signIn(signIn: signIn)
        } catch {
            XCTFail("Error signIn : \(error)")
        }
    }
    
    private func logout() {
        do {
            try sut.signOut()
        } catch {
            XCTFail("Error signOut : \(error)")
        }
    }
    
    private func delateAccount() async {
        do {
            try await sut.deleteAccount()
        } catch {
            XCTFail("Error deleteAccount : \(error)")
        }
    }
    
    private func createAccount() async {
        let register: Register = .mockRegister(email: "mock@mock.com", password: "123456", verifyPassword: "123456", firstName: "TestFirstName", lastName: "TestLastName")
        do {
            try await sut.singUp(register: register)
        } catch {
            XCTFail("Error singUp : \(error)")
        }
    }
}

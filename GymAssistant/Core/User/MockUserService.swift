//
//  MockUserService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 14.10.2024.
//

import Foundation

final class MockUserService: UserService {
    
    var shouldThrowError: Bool = false
    var mockUserInfo: UserInfo?
    
    func getUserInfo(userId: String) async throws -> UserInfo {
        try checkShouldThrowError()
        try validateUserInfoId(userId)
        return try checkUserInfo()
    }
    
    func updateUser(userInfo: UserInfo) async throws {
        try checkShouldThrowError()
        try validateUserInfoId(userInfo)
        self.mockUserInfo = userInfo
    }
    
    func updateUserLogin(userInfo: UserInfo) async throws -> UserInfo {
        try checkShouldThrowError()
        try validateUserInfoId(userInfo)
        let updatedUserInfo = UserInfo(userInfo: userInfo, lastLoginDate: Date())
        self.mockUserInfo = updatedUserInfo
        return updatedUserInfo
    }
    
    func userProgramUpdate(userInfo: UserInfo, programId: Program.ID) async throws -> UserInfo {
        try checkShouldThrowError()
        try validateUserInfoId(userInfo)
        let updatedUserInfo = UserInfo(userInfo: userInfo, programId: programId)
        self.mockUserInfo = updatedUserInfo
        return updatedUserInfo
    }
    
    func userProgramDelete(userInfo: UserInfo) async throws -> UserInfo {
        try checkShouldThrowError()
        try validateUserInfoId(userInfo)
        let updatedUserInfo = UserInfo(userInfo: userInfo, programId: "")
        self.mockUserInfo = updatedUserInfo
        return updatedUserInfo
    }
    
    func userInfoDelete(userInfoId: UserInfo.ID) async throws {
        try checkShouldThrowError()
        try validateUserInfoId(userInfoId)
        self.mockUserInfo = nil
    }
    
    private func checkShouldThrowError() throws {
        if shouldThrowError {
            throw CustomError.customError(title: "Error",
                                          subtitle: "Error")
        }
    }
    
    private func checkUserInfo() throws -> UserInfo {
        guard let mockUserInfo = self.mockUserInfo else {
            throw CustomError.customError(title: "Error",
                                          subtitle: "User not found")
        }
        return mockUserInfo
    }
    
    private func validateUserInfoId(_ userInfo: UserInfo) throws {
        let mockUserInfo = try self.checkUserInfo()
        guard userInfo.id == mockUserInfo.id else {
            throw CustomError.customError(title: "Error",
                                          subtitle: "Id mismatch")
        }
    }
    
    private func validateUserInfoId(_ userInfoId: UserInfo.ID) throws {
        let mockUserInfo = try self.checkUserInfo()
        guard userInfoId == mockUserInfo.id else {
            throw CustomError.customError(title: "Error",
                                          subtitle: "Id mismatch")
        }
    }
}

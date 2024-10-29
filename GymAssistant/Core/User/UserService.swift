//
//  UserService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 12.10.2024.
//

import Foundation

protocol UserService {
    func getUserInfo(userId: String) async throws -> UserInfo
    func updateUser(userInfo: UserInfo) async throws
    func updateUserLogin(userInfo: UserInfo) async throws -> UserInfo
    func userProgramUpdate(userInfo: UserInfo, programId: Program.ID) async throws -> UserInfo
    func userProgramDelete(userInfo: UserInfo) async throws -> UserInfo
    func userInfoDelete(userInfoId: UserInfo.ID) async throws
}

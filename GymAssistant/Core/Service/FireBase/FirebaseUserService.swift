//
//  FirebaseUserService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 12.10.2024.
//

import Foundation
import Firebase

final class FirebaseUserService: UserService {
    
    private let userCollection: CollectionReference
    
    init(userCollection: CollectionReference = Firestore.firestore().collection(FirebasePath.users)) {
        self.userCollection = userCollection
    }
    
    func getUserInfo(userId: String) async throws -> UserInfo {
        guard let userInfo: UserInfo = try await userCollection.getDocument(id: userId) else {
            throw AppAuthError.userNotFound
        }
        return userInfo
    }
    
    func updateUser(userInfo: UserInfo) async throws {
        try await userCollection.updateDocument(document: userInfo)
    }
    
    func updateUserLogin(userInfo: UserInfo) async throws -> UserInfo {
        let newUserInfo: UserInfo = UserInfo(userInfo: userInfo, lastLoginDate: Date())
        try await updateUser(userInfo: newUserInfo)
        return newUserInfo
    }
    
    func userProgramUpdate(userInfo: UserInfo, programId: Program.ID) async throws -> UserInfo {
        let newUserProgram: UserInfo = UserInfo(userInfo: userInfo, programId: programId)
        try await updateUser(userInfo: newUserProgram)
        return newUserProgram
    }
    
    func userProgramDelete(userInfo: UserInfo) async throws -> UserInfo {
        let newUserProgram: UserInfo = UserInfo(userInfo: userInfo, programId: "")
        try await updateUser(userInfo: newUserProgram)
        return newUserProgram
    }
    
    func userInfoDelete(userInfoId: UserInfo.ID) async throws {
        try await userCollection.deleteDocument(id: userInfoId)
    }
}

//
//  UserManager.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 11.10.2024.
//

import Foundation
import Combine

final class UserManager: ObservableObject{
    private let service: UserService
    private let authManager: AuthManager
    
    @Published private(set) var userInfo: UserInfo?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(service: UserService, authManager: AuthManager){
        self.service = service
        self.authManager = authManager
        addSubscribers()
    }
    
    /// Subscribes to authInfo updates in authManager. When a user logs in, UserManager fetches the user’s details and updates their login time.
    private func addSubscribers(){
        authManager.$authInfo
            .sink { [weak self] authInfo in
                guard let authInfo = authInfo else {
                    DispatchQueue.main.async{
                        self?.userInfo = nil
                    }
                    return
                }
                Task{ [weak self] in
                    try await self?.getUserInfo(userId: authInfo.id)
                    try await self?.updateUserLogin()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Fetches user information for the specified user ID.
    @MainActor
    func getUserInfo(userId: String) async throws {
        let userInfo = try await service.getUserInfo(userId: userId)
        self.userInfo = userInfo
    }
    
    /// Updates user information and reflects the latest data in userInfo.
    @MainActor
    func updateUserInfo(update: UserInfo) async throws {
        try await service.updateUser(userInfo: update)
        self.userInfo = update
    }
    
    /// Updates the user's program with the provided program ID, allowing the app to manage program assignments for the user.
    @MainActor
    func userProgramUpdate(programId: Program.ID) async throws {
        guard let userInfo = self.userInfo else {
            throw AppAuthError.userNotFound
        }
        let newUserInfo = try await service.userProgramUpdate(userInfo: userInfo, programId: programId)
        self.userInfo = newUserInfo
    }
    
    /// Removes the assigned program from the user’s data.
    @MainActor
    func userProgramDelete() async throws {
        guard let userInfo = self.userInfo else {
            throw AppAuthError.userNotFound
        }
        let newUserInfo = try await service.userProgramDelete(userInfo: userInfo)
        self.userInfo = newUserInfo
    }
    
    /// Deletes the current user’s information entirely from the system.
    @MainActor
    func userInfoDelete() async throws {
        guard let userInfoId = self.userInfo?.id else {
            throw AppAuthError.userNotFound
        }
        try await service.userInfoDelete(userInfoId: userInfoId)
        self.userInfo = nil
    }
    
    /// Updates the last login time of the current user.
    @MainActor
    private func updateUserLogin() async throws {
        guard let userInfo = self.userInfo else {
            throw AppAuthError.userNotFound
        }
        let newUserInfo = try await service.updateUserLogin(userInfo: userInfo)
        self.userInfo = newUserInfo
    }
}

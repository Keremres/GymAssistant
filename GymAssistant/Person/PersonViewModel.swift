//
//  PersonViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 9.08.2024.
//

import Foundation

@MainActor
final class PersonViewModel: ObservableObject{
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let programManager: ProgramManager
    
    @Published var alert: CustomError? = nil
    @Published var programOutDialog: Bool = false
    @Published var signOutDialog: Bool = false
    @Published var deleteAccountDialog: Bool = false
    
    init(authManager: AuthManager = AppContainer.shared.authManager,
         userManager: UserManager = AppContainer.shared.userManager,
         programManager: ProgramManager = AppContainer.shared.programManager) {
        self.authManager = authManager
        self.userManager = userManager
        self.programManager = programManager
    }
    
    func signOut(){
        do{
            try authManager.signOut()
        } catch {
            handleError(error,
                        title: "Sign Out Error",
                        subtitle: "Please try again.")
        }
    }
    
    func programOut() {
        Task{
            do{
                guard let userInfo = userManager.userInfo else {
                    throw AppAuthError.userNotFound
                }
                guard userInfo.programId != nil , userInfo.programId != "" else {
                    throw AppAuthError.userNotFound
                }
                try await userManager.userProgramDelete()
                programManager.programClear()
            } catch {
                handleError(error,
                            title: "Program Out Error",
                            subtitle: "Sorry try again")
            }
        }
    }
    
    func deleteAccount() {
        Task{
            do{
                guard userManager.userInfo != nil else {
                    throw AppAuthError.userNotFound
                }
                try await userManager.userInfoDelete()
                try await authManager.deleteAccount()
            } catch {
                handleError(error,
                            title: "Delete Account Error",
                            subtitle: "Sorry try again")
            }
        }
    }
    
    private func handleError(_ error: Error, title: String = "Error", subtitle: String = "Try again") {
        switch error {
        case let error as CustomError:
            alert = error
        case let error as AppAuthError:
            alert = .authError(appAuthError: error)
        default:
            alert = CustomError.customError(title: title,
                                            subtitle: subtitle)
        }
    }
}

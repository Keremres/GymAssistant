//
//  ProgramHistoryViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 24.08.2024.
//

import Foundation

@MainActor
final class ProgramHistoryViewModel: ObservableObject{
    
    private let programManager: ProgramManager
    private let userManager: UserManager
    
    private var tasks: [Task<Void, Never>] = []
    
    @Published var programHistory: [Program] = []
    
    @Published var alert: CustomError? = nil
    
    init(programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager) {
        self.programManager = programManager
        self.userManager = userManager
        getProgramHistory()
    }
    
    func getProgramHistory() {
        let task = Task{
            do{
                guard let userInfo = userManager.userInfo else {
                    throw AppAuthError.userNotFound
                }
                self.programHistory = try await programManager.getProgramHistory(userInfo: userInfo)
            } catch {
                handleError(error, title: "Fetch Error", subtitle: "Sorry try again")
            }
        }
        tasks.append(task)
    }
    
    func programDelete(program: Program) {
        Task{
            do {
                guard let userInfo = userManager.userInfo else {
                    throw AppAuthError.userNotFound
                }
                guard let index = programHistory.firstIndex(where: { $0.id == program.id }) else {
                    throw CustomError.customError(title: "Delete Error",
                                                  subtitle: "The program to be deleted could not be found.")
                }
                try await programManager.deleteProgramHistory(userInfo: userInfo, programId: program.id)
                if userInfo.programId == program.id {
                    try await userManager.userProgramDelete()
                }
                programHistory.remove(at: index)
            } catch {
                handleError(error, title: "Delete Error", subtitle: "Sorry try again")
            }
        }
    }
    
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
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

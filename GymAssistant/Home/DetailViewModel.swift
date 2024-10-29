//
//  DetailViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 21.10.2024.
//

import Foundation

@MainActor
final class DetailViewModel: ObservableObject {
    private let userManager: UserManager
    private let programManager: ProgramManager
    
    @Published var alert: CustomError? = nil
    
    init(userManager: UserManager, programManager: ProgramManager) {
        self.userManager = userManager
        self.programManager = programManager
    }
    
    func saveDay(dayModel: DayModel) async {
        do{
            guard let userInfo = userManager.userInfo else { return }
            try await programManager.saveDay(userInfo: userInfo, dayModel: dayModel)
        } catch {
            handleError(error, title: "Save Day Error", subtitle: "Try again")
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

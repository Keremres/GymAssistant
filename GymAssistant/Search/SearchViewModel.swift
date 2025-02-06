//
//  SearchViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.08.2024.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject{
    
    private let programManager: ProgramManager
    private let userManager: UserManager
    
    @Published var programs: [Program] = []
    @Published var text: String = ""
    
    @Published var alert: CustomError? = nil
    @Published var showDialog: Bool = false
    
    private(set) var tasks: [Task<Void, Never>] = []
    
    init(programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager){
        self.programManager = programManager
        self.userManager = userManager
        getAllPrograms()
    }
    
    func getAllPrograms() {
        let task = Task{
            do{
                self.programs = try await programManager.getPrograms()
            } catch {
                handleError(error, title: "Error", subtitle: "Sorry try again")
            }
        }
        tasks.append(task)
    }
    
    func useProgram(program: Program) {
        Task{
            let programSetDate = setDate(program: program)
            do{
                guard let userInfo = userManager.userInfo else {
                    throw AppAuthError.userNotFound
                }
                try await programManager.useProgram(userInfo: userInfo,
                                                    program: programSetDate)
                try await userManager.userProgramUpdate(programId: program.id)
            } catch {
                handleError(error, title: "Use Error", subtitle: "Sorry try again")
            }
        }
    }
    
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    private func setDate(program: Program) -> Program {
        var programSetDate = program
        programSetDate.week[0].date = Date()
        for (dayIndex, day) in programSetDate.week[0].day.enumerated(){
            for (exerciseIndex, _) in day.exercises.enumerated(){
                programSetDate.week[0].day[dayIndex].exercises[exerciseIndex].date = Date()
            }
        }
        return programSetDate
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

//
//  CreateViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import Foundation

@MainActor
final class CreateViewModel: ObservableObject {
    
    private let programManager: ProgramManager = AppContainer.shared.programManager
    private let userManager: UserManager = AppContainer.shared.userManager
    
    @Published var program: Program = Program.baseProgram()
    
    @Published var alert: CustomError? = nil
    @Published var showDialog: Bool = false
    
    func addDay(){
        checkIfWeekExists()
        self.program.week[0].day.append(DayModel.baseDay())
    }
    
    func addExercises(dayModel: DayModel){
        checkIfWeekExists()
        if let index = self.program.week[0].day.firstIndex(where: { $0.id == dayModel.id }) {
            self.program.week[0].day[index].exercises.append(Exercises.exerciseList[0])
        } else {
            var newDayModel = dayModel
            newDayModel.exercises.append(Exercises.exerciseList[0])
            self.program.week[0].day.append(newDayModel)
        }
    }
    
    func deleteDay(id: DayModel.ID){
        guard !self.program.week.isEmpty else { return }
        if let index = self.program.week[0].day.firstIndex(where: {$0.id == id}){
            self.program.week[0].day.remove(at: index)
        }
    }
    
    func deleteExercise(idExercise: Exercises.ID, idDayModel: DayModel.ID){
        guard !self.program.week.isEmpty else { return }
        if let dayIndex = self.program.week[0].day.firstIndex(where: {$0.id == idDayModel}){
            if let exercisesIndex = self.program.week[0].day[dayIndex].exercises.firstIndex(where: {$0.id == idExercise}){
                self.program.week[0].day[dayIndex].exercises.remove(at: exercisesIndex)
            }
        }
    }
    
    func create() async {
        do{
            guard let userInfo = userManager.userInfo else {
                throw CustomError.authError(appAuthError: .userNotFound)
            }
            try await programManager.useProgram(userInfo: userInfo, program: self.program)
            try await userManager.userProgramUpdate(programId: self.program.id)
        } catch {
            handleError(error,
                        title: "Create Error",
                        subtitle: "Try again")
        }
    }
    
    func publishProgram() async {
        do{
            try await programManager.publishProgram(program: self.program)
        }catch{
            alert = CustomError.customError(title: "Publish Error",
                                            subtitle: "Try again")
        }
    }
    
    private func checkIfWeekExists() {
        if self.program.week.count <= 0 {
            self.program.week.append(WeekModel.baseWeek())
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

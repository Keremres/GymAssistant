//
//  MockProgramService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 14.10.2024.
//

import Foundation

final class MockProgramService: ProgramService {
    
    var mockProgram: Program?
    var mockUserProgramHistory: [Program] = []
    @Published var mockPublishedPrograms: [Program] = []
    var shouldThrowError: Bool = false
    
    func useProgram(userInfo: UserInfo, program: Program) async throws {
        try checkShouldThrowError()
        self.mockProgram = program
        self.mockUserProgramHistory.append(program)
    }
    
    func publishProgram(program: Program) async throws {
        try checkShouldThrowError()
        self.mockPublishedPrograms.append(program)
    }
    
    func getProgram(userInfo: UserInfo) async throws -> Program {
        try checkShouldThrowError()
        guard let mockProgram = self.mockProgram else {
            throw CustomError.customError(title: "Program not found",
                                          subtitle: "Program not found.")
        }
        guard mockProgram.id == userInfo.programId, userInfo.programId != "" else {
            throw CustomError.customError(title: "Program not found",
                                          subtitle: "User has not used a program yet.")
        }
        return mockProgram
    }
    
    func getPrograms() async throws -> [Program] {
        try checkShouldThrowError()
        guard !self.mockPublishedPrograms.isEmpty else {
            throw CustomError.customError(title: "Program not found",
                                          subtitle: "Program not found.")
        }
        return self.mockPublishedPrograms
    }
    
    func getProgramHistory(userInfo: UserInfo) async throws -> [Program] {
        try checkShouldThrowError()
        guard !self.mockUserProgramHistory.isEmpty else {
            throw CustomError.customError(title: "Program not found",
                                          subtitle: "Program not found.")
        }
        return self.mockUserProgramHistory
    }
    
    func deleteUserProgramHistory(userInfo: UserInfo, programId: Program.ID) async throws {
        try checkShouldThrowError()
        guard self.mockUserProgramHistory.first(where: { $0.id == programId }) != nil else {
            throw CustomError.customError(title: "Program not found",
                                          subtitle: "Program not found.")
        }
        self.mockUserProgramHistory.removeAll(where: { $0.id == programId })
        if self.mockProgram?.id == programId {
            self.mockProgram = nil
        }
    }
    
    func newWeek(userInfo: UserInfo, program: Program) async throws -> Program {
        try checkShouldThrowError()
        guard let weekLast = program.week.last else {
            throw CustomError.customError(title: "Error",
                                          subtitle: "No Week")
        }
        let newWeek = newWeekMap(lastWeek: weekLast)
        var newProgram = program
        newProgram.week.append(newWeek)
        return newProgram
    }
    
    func saveDay(userInfo: UserInfo, dayModel: DayModel, program: Program) async throws -> Program {
        try checkShouldThrowError()
        var updatedProgram = program
        guard let weekIndex = updatedProgram.week.firstIndex(where: { $0.day.contains(where: { $0.id == dayModel.id }) }) else {
            throw CustomError.customError(title: "Error",
                                          subtitle: "Week Not Found")
        }
        guard let dayIndex = updatedProgram.week[weekIndex].day.firstIndex(where: { $0.id == dayModel.id }) else {
            throw CustomError.customError(title: "Error",
                                          subtitle: "No Day")
        }
        let nowDayModel = updateExerciseDates(dayModel: dayModel)
        updatedProgram.week[weekIndex].day[dayIndex] = nowDayModel
        return updatedProgram
    }
    
    func chartCalculator(exerciseId: Exercises.ID, program: Program) -> [ChartModel] {
        var chartModel: [ChartModel] = []
        for week in program.week {
            for day in week.day {
                for exercise in day.exercises {
                    if exercise.id == exerciseId {
                        chartModel.append(ChartModel(date: exercise.date, value: exercise.weight))
                    }
                }
            }
        }
        return chartModel
    }
    
    private func checkShouldThrowError() throws {
        if shouldThrowError {
            throw CustomError.customError(title: "Error",
                                          subtitle: "Error")
        }
    }
    
    private func newWeekMap(lastWeek: WeekModel) -> WeekModel {
        let newDays = lastWeek.day.map { dayModel -> DayModel in
            let newExercises = dayModel.exercises.map { exercise -> Exercises in
                var newExercise = exercise
                if(exercise.again >= exercise.againEnd){
                    newExercise.again = newExercise.againStart
                    newExercise.weight += 2.5
                    newExercise.date = Date()
                }else{
                    newExercise.again += 1
                    newExercise.date = Date()
                }
                return newExercise
            }
            return DayModel(day: dayModel.day, exercises: newExercises)
        }
        return WeekModel(day: newDays)
    }
    
    private func updateExerciseDates(dayModel: DayModel) -> DayModel {
        var newDayModel = dayModel
        for index in newDayModel.exercises.indices {
            newDayModel.exercises[index].date = Date()
        }
        return newDayModel
    }
}

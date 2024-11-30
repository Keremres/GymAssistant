//
//  FirebaseProgramService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 9.09.2024.
//

import Foundation
import Firebase

final class FirebaseProgramService: ProgramService{
    
    private func userProgramCollection(_ userInfo: UserInfo) -> CollectionReference {
        Firestore.firestore().collection(FirebasePath.users).document(userInfo.id).collection(FirebasePath.program)
    }
    
    private let programCollection: CollectionReference = Firestore.firestore().collection(FirebasePath.programs)
    
    func useProgram(userInfo: UserInfo, program: Program) async throws {
        try await userProgramCollection(userInfo).setDocument(document: program)
    }
    
    func publishProgram(program: Program) async throws {
        try await programCollection.setDocument(document: program)
    }
    
    func getProgram(userInfo: UserInfo) async throws -> Program {
        guard let programId = userInfo.programId, programId != "" else {
            throw CustomError.customError(title: "No program found", subtitle: "User has no program")
        }
        let program: Program = try await userProgramCollection(userInfo).getDocument(id: programId)
        return program
    }
    
    func getPrograms() async throws -> [Program] {
        let programs: [Program] = try await programCollection.getAllDocuments()
        return programs
    }
    
    func getProgramHistory(userInfo: UserInfo) async throws -> [Program] {
        let programs: [Program] = try await userProgramCollection(userInfo).getAllDocuments()
        return programs
    }
    
    func deleteUserProgramHistory(userInfo: UserInfo, programId: Program.ID) async throws {
        try await userProgramCollection(userInfo).deleteDocument(id: programId)
    }
    
    func newWeek(userInfo: UserInfo, program: Program) async throws -> Program {
        var program: Program = program
        guard let lastWeek = program.week.last else {
            throw CustomError.customError(title: "No previous week",
                                          subtitle: "Please start a new week")
        }
        if Date.getCurrentWeekInt(date: lastWeek.date) != Date.getCurrentWeekInt(date: Date()){
            let newWeek = newWeekMap(lastWeek: lastWeek)
            program.week.append(newWeek)
            try await userProgramCollection(userInfo).updateDocument(document: program)
            return program
        }
        return program
    }
    
    func saveDay(userInfo: UserInfo, dayModel: DayModel, program: Program) async throws -> Program {
        let newProgram: Program = try setDayDate(dayModel: dayModel, program: program)
        try await userProgramCollection(userInfo).updateDocument(document: newProgram)
        return newProgram
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
    
    private func setDayDate(dayModel: DayModel, program: Program) throws -> Program {
        var updatedProgram = program
        guard let weekIndex = updatedProgram.week.firstIndex(where: { $0.day.contains(where: { $0.id == dayModel.id }) }) else {
            throw CustomError.customError(title: "Error",
                                          subtitle: "Week Not Found")
        }
        guard let dayIndex = updatedProgram.week[weekIndex].day.firstIndex(where: { $0.id == dayModel.id }) else {
            throw CustomError.customError(title: "Error",
                                          subtitle: "No Day")
        }
        var nowDayModel = dayModel
        for index in nowDayModel.exercises.indices {
            nowDayModel.exercises[index].date = Date()
        }
        updatedProgram.week[weekIndex].day[dayIndex] = nowDayModel
        return updatedProgram
    }
}

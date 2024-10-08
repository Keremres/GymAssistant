//
//  ProgramService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 9.09.2024.
//

import Foundation
import Firebase

@MainActor
final class ProgramService: ObservableObject{
    static let shared = ProgramService()
    
    @Published var program: Program? = nil /*Program.MOCK_PROGRAM*/
    
    func getProgram(user: User) async throws {
            if let programId = user.programId, !programId.isEmpty{
                let snapshot = try await Firestore.firestore().collection("users").document(user.id).collection("program").document(programId).getDocument()
                self.program = try? snapshot.data(as: Program.self)
            }else{
                self.program = nil
            }
    }
    
    func newWeek(user: User) async throws {
        guard let program = program else { return }
        guard let lastWeek = program.week.last else { return }
        if Date.getCurrentWeekInt(date: lastWeek.date) != Date.getCurrentWeekInt(date: Date()){
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
            let newWeek = WeekModel(day: newDays)
            self.program?.week.append(newWeek)
            guard let encodedProgram = try? Firestore.Encoder().encode(self.program) else { return }
            try await Firestore.firestore().collection("users").document(user.id).collection("program").document(program.id).updateData(encodedProgram)
        }
    }
    
    func saveDay(user: User, dayModel: DayModel) async throws {
        if let program = self.program {
            for (weekIndex, week) in program.week.enumerated() {
                for (dayIndex, day) in week.day.enumerated() {
                    if day.id == dayModel.id {
                        var newExercises = dayModel.exercises
                        for index in newExercises.indices {
                            newExercises[index].date = Date()
                        }
                        self.program!.week[weekIndex].day[dayIndex].exercises = newExercises
                        guard let encodedProgram = try? Firestore.Encoder().encode(self.program) else { return }
                        try await Firestore.firestore().collection("users").document(user.id).collection("program").document(program.id).updateData(encodedProgram)
                    }
                }
            }
        }
    }
    
    func chartCalculator(exerciseId: Exercises.ID) -> [ChartModel] {
        var chartModel: [ChartModel] = []
        
        if let program = self.program {
            for week in program.week {
                for day in week.day {
                    for exercise in day.exercises {
                        if exercise.id == exerciseId {
                            chartModel.append(ChartModel(date: exercise.date, value: exercise.weight))
                        }
                    }
                }
            }
        }
        
        return chartModel
    }
}

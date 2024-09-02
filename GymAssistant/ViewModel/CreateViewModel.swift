//
//  CreateViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import Foundation
import SwiftUI
import Firebase

final class CreateViewModel: ObservableObject {
    @Published var program: Program = Program(id: UUID().uuidString, programName: "", programClass: "Powerlifting", week: [WeekModel(id: UUID().uuidString, date: Date(), day: [DayModel(id: UUID().uuidString, day: "Monday", exercises: [Exercises.exerciseList[0]])])])
    @Published var error: Bool = false
    @Published var errorTitle: String = ""
    @Published var errorMessage: String = ""
    
    @MainActor
    func addDay(){
        self.program.week[0].day.append(newDay())
    }
    
    @MainActor
    func addExercises(id: DayModel.ID){
        if let index = self.program.week[0].day.firstIndex(where: {$0.id == id}){
            self.program.week[0].day[index].exercises.append(Exercises.exerciseList[0])
        }
    }
    
    @MainActor
    func deleteDay(id: DayModel.ID){
        if let index = self.program.week[0].day.firstIndex(where: {$0.id == id}){
            self.program.week[0].day.remove(at: index)
        }
    }
//    func deleteExercise(idExercise: Exercises.ID, idDayModel: DayModel.ID){
//        if let dayIndex = self.program.week[0].day.firstIndex(where: {$0.id == idDayModel}){
//            if let exercisesIndex = self.program.week[0].day[dayIndex].exercises.firstIndex(where: {$0.id == idExercise}){
//                self.program.week[0].day[dayIndex].exercises.remove(at: exercisesIndex)
//            }
//        }
//    }
    func newDay() -> DayModel {
        return DayModel(id: UUID().uuidString, day: "Monday", exercises: [Exercises.exerciseList[0]])
    }
    
    @MainActor
    func create(user: User) async throws {
        do{
            guard let encodedProgram = try? Firestore.Encoder().encode(program) else { return }
            try await Firestore.firestore().collection("users").document(user.id).collection("program").document(program.id).setData(encodedProgram)
            var userUpdate = user
            userUpdate.programId = program.id
            guard let encodedUser = try? Firestore.Encoder().encode(userUpdate) else { return }
            try await Firestore.firestore().collection("users").document(user.id).updateData(encodedUser)
            try await AuthService.shared.loadUserData()
        }catch let error as AppAuthError{
            errorTitle = "Error"
            errorMessage = error.localizedDescription
            self.error = true
            print(error.localizedDescription)
        }catch{
            errorTitle = "Error"
            self.error = true
            print(error.localizedDescription)
        }
    }
    
    func publishProgram() async throws {
        do{
            guard let encodedProgram = try? Firestore.Encoder().encode(program) else { return }
            try await Firestore.firestore().collection("programs").document(program.id).setData(encodedProgram)
        }catch let error as AppAuthError{
            errorTitle = "Error"
            errorMessage = error.localizedDescription
            self.error = true
            print(error.localizedDescription)
        }catch{
            errorTitle = "Error"
            self.error = true
            print(error.localizedDescription)
        }
    }
}

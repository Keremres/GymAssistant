//
//  SearchViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.08.2024.
//

import Foundation
import Firebase

@MainActor
final class SearchViewModel: ObservableObject{
    
    private let programService = ProgramService.shared
    private let mainTabViewModel = MainTabViewModel.shared
    
    @Published var programs: [Program] = []
    
    @Published var alert: CustomError? = nil

    init(){
        Task{
            try await getAllPrograms()
        }
    }
    
    func getAllPrograms() async throws {
        do{
            let snapshot = try await Firestore.firestore().collection("programs").getDocuments()
            self.programs = try snapshot.documents.compactMap { document in
                try document.data(as: Program.self)
            }
        }catch{
            alert = CustomError.customError(title: "Error", subtitle: "Sorry try again")
        }
    }
    
    func useProgram(user: User, program: Program) async throws {
        var programSetDate = program
        programSetDate.week[0].date = Date()
        for (dayIndex, day) in programSetDate.week[0].day.enumerated(){
            for (exerciseIndex, _) in day.exercises.enumerated(){
                programSetDate.week[0].day[dayIndex].exercises[exerciseIndex].date = Date()
            }
        }
        do{
            guard let encodedProgram = try? Firestore.Encoder().encode(programSetDate) else { return }
            try await Firestore.firestore().collection("users").document(user.id).collection("program").document(program.id).setData(encodedProgram)
            programService.program = programSetDate
            var userUpdate = user
            userUpdate.programId = program.id
            guard let encodedUser = try? Firestore.Encoder().encode(userUpdate) else { return }
            try await Firestore.firestore().collection("users").document(user.id).updateData(encodedUser)
            try await AuthService.shared.loadUserData()
            mainTabViewModel?.newUser()
        }catch let error as AppAuthError{
            alert = CustomError.authError(appAuthError: error)
        }catch{
            alert = CustomError.customError(title: "Use Error", subtitle: "Sorry try again")
        }
    }
}

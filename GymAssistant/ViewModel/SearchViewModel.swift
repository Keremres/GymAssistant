//
//  SearchViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.08.2024.
//

import Foundation
import Firebase

final class SearchViewModel: ObservableObject{
    @Published var programs: [Program] = []
    
    @Published var error: Bool = false
    @Published var errorTitle: String = ""
    @Published var errorMessage: String = ""
    
    init(){
        Task{
            try await getAllPrograms()
        }
    }
    
    @MainActor
    func getAllPrograms() async throws {
        do{
            let snapshot = try await Firestore.firestore().collection("programs").getDocuments()
            self.programs = try snapshot.documents.compactMap { document in
                try document.data(as: Program.self)
            }
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
    
    @MainActor
    func useProgram(user: User, program: Program, homeViewModel: HomeViewModel) async throws {
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
            homeViewModel.program = programSetDate
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
    
    @MainActor
    func errorClear(){
        error = false
        errorTitle = ""
        errorMessage = ""
    }
}

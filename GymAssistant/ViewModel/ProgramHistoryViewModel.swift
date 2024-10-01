//
//  ProgramHistoryViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 24.08.2024.
//

import Foundation
import Firebase

@MainActor
final class ProgramHistoryViewModel: ObservableObject{
    
    private let programService = ProgramService.shared
    
    @Published var programHistory: [Program] = []
    
    @Published var alert: CustomError? = nil

    func programHistory(user: User) async throws {
        do{
            let snapshot = try await Firestore.firestore().collection("users").document(user.id).collection("program").getDocuments()
            self.programHistory = try snapshot.documents.compactMap { document in
                try document.data(as: Program.self)
            }
        }catch{
            alert = CustomError.customError(title: "Fetch Error", subtitle: "Sorry try again")
        }
        
    }
    
    func programDelete(user: User, program: Program) async {
        let programId = program.id
        
        do {
            try await Firestore.firestore()
                .collection("users")
                .document(user.id)
                .collection("program")
                .document(programId).delete()
            
            if let index = programHistory.firstIndex(where: { $0.id == program.id }) {
                programHistory.remove(at: index)
            }
            if programService.program?.id == programId{
                programService.program = nil
            }
        } catch {
            alert = CustomError.customError(title: "Delete Error", subtitle: "Sorry try again")
        }
    }
}

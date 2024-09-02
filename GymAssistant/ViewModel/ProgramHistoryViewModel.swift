//
//  ProgramHistoryViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 24.08.2024.
//

import Foundation
import Firebase

final class ProgramHistoryViewModel: ObservableObject{
    @Published var programHistory: [Program] = []
    @Published var error: Bool = false
    @Published var errorTitle: String = ""
    @Published var errorMessage: String = ""
    
    @MainActor
    func programHistory(user: User) async throws {
        do{
            let snapshot = try await Firestore.firestore().collection("users").document(user.id).collection("program").getDocuments()
            self.programHistory = try snapshot.documents.compactMap { document in
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
                } catch let error as AppAuthError {
                    errorTitle = "Error"
                    errorMessage = error.localizedDescription
                    self.error = true
                    print(error.localizedDescription)
                } catch {
                    errorTitle = "Error"
                    errorMessage = error.localizedDescription
                    self.error = true
                    print(error.localizedDescription)
                }
    }
}

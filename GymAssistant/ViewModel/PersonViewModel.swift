//
//  PersonViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 9.08.2024.
//

import Foundation
import Firebase

final class PersonViewModel: ObservableObject{
    @Published var error: Bool = false
    @Published var errorTitle: String = ""
    @Published var errorMessage: String = ""
    
    func signOut() async {
        await AuthService.shared.signout()
    }
    
    func programOut(user: User) async throws {
        if user.programId != nil{
            do{
                var userUpdate = user
                userUpdate.programId = ""
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
        
    }
}

//
//  PersonViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 9.08.2024.
//

import Foundation
import Firebase

@MainActor
final class PersonViewModel: ObservableObject{
    
    private let programService = ProgramService.shared
    private let mainTabViewModel = MainTabViewModel.shared
    
    @Published var alert: CustomError? = nil

    func signOut(){
        AuthService.shared.signout()
    }
    
    func programOut(user: User) async throws {
        if user.programId != nil{
            do{
                var userUpdate = user
                userUpdate.programId = ""
                guard let encodedUser = try? Firestore.Encoder().encode(userUpdate) else { return }
                try await Firestore.firestore().collection("users").document(user.id).updateData(encodedUser)
                programService.program = nil
                try await AuthService.shared.loadUserData()
                mainTabViewModel?.newUser()
            }catch let error as AppAuthError{
                alert = .authError(appAuthError: error)
            }catch{
                alert = CustomError.customError(title: "Program Out Error", subtitle: "Sorry try again")
            }
        }
    }
}

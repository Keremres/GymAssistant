//
//  RegisterViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import Foundation

final class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var verifyPassword: String = ""
    
    @Published var errorTitle = ""
    @Published var errorMessage = ""
    @Published var error: Bool = false
    
    @MainActor
    func createUser() async throws {
        guard validate() else {
            return
        }
        
        do{
            try await AuthService.shared.createUser(email: email, password: password, username: username)
            DispatchQueue.main.async{
                self.username = ""
                self.email = ""
                self.password = ""
                self.verifyPassword = ""
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
    func validate() -> Bool {
        errorClear()
        
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorTitle = "Username Error"
            errorMessage = "Plase enter username"
            error = true
            return false
        }
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorTitle = "Email Error"
            errorMessage = "Plase enter email"
            error = true
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorTitle = "Email Error"
            errorMessage = "Plase enter a valid email"
            error = true
            return false
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorTitle = "Password Error"
            errorMessage = "Plase enter password"
            error = true
            return false
        }
        guard password.count >= 6 else{
            errorTitle = "Password Error"
            errorMessage = "Plase enter a password longer than 6 characters"
            error = true
            return false
        }
        guard password == verifyPassword else {
            errorTitle = "Password Error"
            errorMessage = "Your password does not match"
            error = true
            return false
        }
        
        return true
    }
    
    @MainActor
    func errorClear(){
        error = false
        errorTitle = ""
        errorMessage = ""
    }
}

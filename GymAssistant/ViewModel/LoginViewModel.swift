//
//  LoginViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import Foundation

final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var forgotPassword: String = ""
    
    @Published var showForgotPassword: Bool = false
    
    @Published var errorTitle = ""
    @Published var errorMessage = ""
    @Published var error: Bool = false
    
    @MainActor
    func signIn() async throws {
        guard validate() else {
            return
        }
        
        do{
            try await AuthService.shared.login(withEmail: email, password: password)
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
    func resetPassword(email: String) async throws {
        do{
            try await AuthService.shared.resetPassword(email: email)
            showForgotPassword = false
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
        
        return true
    }
    
    @MainActor
    func errorClear(){
        error = false
        errorTitle = ""
        errorMessage = ""
    }
}

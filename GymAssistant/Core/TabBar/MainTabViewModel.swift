//
//  MainTabViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 22.08.2024.
//

import Foundation

final class MainTabViewModel: ObservableObject{
    @Published var user: User
    
    @MainActor
    init(user: User) {
        self.user = user
        newUser()
    }
    
    @MainActor
    func newUser(){
        if let newUser = AuthService.shared.currentUser {
            self.user = newUser
        }
    }
}

//
//  ContentViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.07.2024.
//
import FirebaseAuth
import Foundation
import Firebase
import Combine

final class ContentViewModel: ObservableObject {
    
    static let contentViewModel = ContentViewModel()
    
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init(){
        setupSubscibers()
    }
    
    func setupSubscibers(){
        service.$userSession.sink{ [weak self] userSession in
            self?.userSession = userSession
        }
        .store(in: &cancellables)
        
        service.$currentUser.sink{ [weak self] currentUser in
            self?.currentUser = currentUser
        }
        .store(in: &cancellables)
    }
}

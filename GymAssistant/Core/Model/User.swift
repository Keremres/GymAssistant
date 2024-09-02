//
//  User.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.07.2024.
//

import Foundation

struct User: Identifiable, Hashable, Codable {
    let id: String
    var username: String
    let email: String
    var programId: String?
    
    var initials: String{
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: username) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User{
    static let MOCK_USER: User = .init(id: UUID().uuidString, username: "kerem", email: "mail")
}

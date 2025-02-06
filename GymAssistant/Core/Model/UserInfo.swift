//
//  UserInfo.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.07.2024.
//

import Foundation
import FirebaseAuth

struct UserInfo: Codable, Sendable, Hashable, Identifiable, IdentifiableByString {
    let id: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let title: String?
    let photoURL: String?
    let creationDate: Date?
    let lastLoginDate: Date?
    let programId: String?
    
    var initials: String{
        guard let firstName else { return "" }
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: firstName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    
    init(authInfo: AuthInfo,
         email: String? = nil,
         firstName: String? = nil,
         lastName: String? = nil,
         title: String? = nil,
         photoURL: String? = nil,
         creationDate: Date? = nil,
         lastLoginDate: Date? = nil,
         programId: String? = nil){
        self.id = authInfo.id
        self.email = email ?? authInfo.email
        self.firstName = firstName
        self.lastName = lastName
        self.title = title
        self.photoURL = photoURL ?? authInfo.photoUrl
        self.creationDate = creationDate
        self.lastLoginDate = lastLoginDate
        self.programId = programId
    }
    
    init(userInfo: UserInfo,
         email: String? = nil,
         firstName: String? = nil,
         lastName: String? = nil,
         title: String? = nil,
         photoURL: String? = nil,
         lastLoginDate: Date? = nil,
         programId: String? = nil){
        self.id = userInfo.id
        self.email = email ?? userInfo.email
        self.firstName = firstName ?? userInfo.firstName
        self.lastName = lastName ?? userInfo.lastName
        self.title = title ?? userInfo.title
        self.photoURL = photoURL ?? userInfo.photoURL
        self.creationDate = userInfo.creationDate
        self.lastLoginDate = lastLoginDate ?? userInfo.lastLoginDate
        self.programId = programId == "" ? nil : programId ?? userInfo.programId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.creationDate = try container.decodeIfPresent(Date.self, forKey: .creationDate)
        self.lastLoginDate = try container.decodeIfPresent(Date.self, forKey: .lastLoginDate)
        self.programId = try container.decodeIfPresent(String.self, forKey: .programId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.creationDate, forKey: .creationDate)
        try container.encodeIfPresent(self.lastLoginDate, forKey: .lastLoginDate)
        try container.encodeIfPresent(self.programId, forKey: .programId)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, title
        case firstName = "first_name"
        case lastName = "last_name"
        case photoURL = "photo_url"
        case creationDate = "creation_date"
        case lastLoginDate = "last_login_date"
        case programId = "program_id"
    }
    
    static func userInfoMock(id: String? = nil, email: String? = nil, photoUrl: String? = nil, isAnonymous: Bool? = nil, title: String? = nil, creationDate: Date? = nil, lastLoginDate: Date? = nil, programId: String? = nil) -> UserInfo {
        return UserInfo(authInfo: .authInfoMock(id: id, email: email, photoUrl: photoUrl, isAnonymous: isAnonymous), title: title, creationDate: creationDate, lastLoginDate: lastLoginDate, programId: programId)
    }
}

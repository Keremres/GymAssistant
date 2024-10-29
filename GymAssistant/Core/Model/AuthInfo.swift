//
//  AuthInfo.swift
//  META
//
//  Created by Kerem RESNENLİ on 7.10.2024.
//

import Foundation
import FirebaseAuth

struct AuthInfo: Codable, Sendable, Identifiable, IdentifiableByString{
    let id: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.id = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case photoUrl = "photo_url"
        case isAnonymous = "is_anonymous"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.isAnonymous = try container.decode(Bool.self, forKey: .isAnonymous)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(photoUrl, forKey: .photoUrl)
    }
    
    private init(id: String, email: String?, photoUrl: String? = nil, isAnonymous: Bool){
        self.id = id
        self.email = email
        self.photoUrl = photoUrl
        self.isAnonymous = isAnonymous
    }
    
    static let mock: AuthInfo = .init(id: "mock", email: "mock@mock.com", photoUrl: nil, isAnonymous: false)
    
    static func mockRegister(id: String = "mock" ,register: Register, photoUrl: String? = nil, isAnonymous: Bool = false) -> AuthInfo {
        return AuthInfo(id: id, email: register.email, photoUrl: photoUrl, isAnonymous: isAnonymous)
    }
}

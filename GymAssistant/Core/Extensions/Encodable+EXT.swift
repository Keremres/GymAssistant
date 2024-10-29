//
//  Encodable+EXT.swift
//  META
//
//  Created by Kerem RESNENLİ on 6.10.2024.
//

import Foundation

public extension Encodable {
    func asJsonDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

//
//  IdentifiableByString.swift
//  META
//
//  Created by Kerem RESNENLİ on 6.10.2024.
//

import Foundation

public protocol IdentifiableByString: Identifiable {
    var id: String { get }
}

//
//  Query+EXT.swift
//  META
//
//  Created by Kerem RESNENLİ on 6.10.2024.
//

import Foundation
import FirebaseFirestore

extension Query {
    
    enum QueryError: Error {
            case noDocumentsFound
        }
    
    /// Get all existing documents.
    func getAllDocuments<T:Codable & IdentifiableByString>() async throws -> [T] {
            try await self.getDocuments(as: [T].self)
        }
    
    func getDocuments<T:Decodable>(as type: [T].Type) async throws -> [T] {
            let snapshot = try await self.getDocuments()
            return try snapshot.documents.map({ try $0.data(as: T.self) })
        }
    
    // Note: similar to DocumentReference.addSnapshotStream

    func addSnapshotStream<T: Decodable>(as type: [T].Type, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error> {
        var didConfigureListener: Bool = false
        
        let stream = AsyncThrowingStream([T].self) { continuation in
            let listener = self.addSnapshotListener { querySnapshot, error in
                guard error == nil else {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    continuation.finish(throwing: QueryError.noDocumentsFound)
                    return
                }
                
                do {
                    let items = try documents.compactMap({ try $0.data(as: T.self) })
                    continuation.yield(items)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            if !didConfigureListener {
                didConfigureListener = true
                onListenerConfigured(listener)
            }
        }
        
        return stream
    }
}

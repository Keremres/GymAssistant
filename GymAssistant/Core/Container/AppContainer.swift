//
//  AppContainer.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 1.11.2024.
//

import Foundation
import Swinject

final class AppContainer {
    static let shared = AppContainer()
    private let container = Container()
    
    private init(){
        registerDependencies()
    }
    
    /// Lazily resolves and provides an instance of `AuthManager` which handles user authentication logic.
    /// - Uses `FirebaseAuthService` as its underlying service for authentication operations.
    /// - Returns: The `AuthManager` instance, or triggers a fatal error if not registered.
    var authManager: AuthManager {
        guard let instance = container.resolve(AuthManager.self) else {
            fatalError("AuthManager is not registered")
        }
        return instance
    }
    
    /// Lazily resolves and provides an instance of `UserManager` which manages user-specific data.
    /// - Uses `FirebaseUserService` to handle user data operations.
    /// - Requires an instance of `AuthManager` to manage user authentication.
    /// - Returns: The `UserManager` instance, or triggers a fatal error if not registered.
    var userManager: UserManager {
        guard let instance = container.resolve(UserManager.self) else {
            fatalError("UserManager is not registered")
        }
        return instance
    }
    
    /// Lazily resolves and provides an instance of `ProgramManager`, responsible for managing user programs.
    /// - Uses `FirebaseProgramService` to handle program-related operations.
    /// - Returns: The `ProgramManager` instance, or triggers a fatal error if not registered.
    var programManager: ProgramManager {
        guard let instance = container.resolve(ProgramManager.self) else {
            fatalError("ProgramManager is not registered")
        }
        return instance
    }
    
    /// Registers dependencies within the `AppContainer` to ensure that each service and manager has a single, shared instance throughout the app.
    ///
    /// The `.inObjectScope(.container)` setting ensures that each manager returns the same instance whenever resolved, preventing multiple instances of the same manager.
    private func registerDependencies(){
        // Register Firebase-based services for dependency injection
        container.register(FirebaseAuthService.self){ _ in FirebaseAuthService()}
        container.register(FirebaseUserService.self){ _ in FirebaseUserService()}
        container.register(FirebaseProgramService.self){ _ in FirebaseProgramService()}
        
        // Register AuthManager with FirebaseAuthService
        // `AuthManager` is scoped to `.container` to ensure only one instance is ever created and shared
        container.register(AuthManager.self){ r in AuthManager(service: r.resolve(FirebaseAuthService.self)!)}
            .inObjectScope(.container)
        
        // Register UserManager with FirebaseUserService and AuthManager
        // Scoped to `.container` so that the same instance is provided throughout the app, preventing different references
        container.register(UserManager.self){ r in UserManager(service: r.resolve(FirebaseUserService.self)!,
                                                               authManager: r.resolve(AuthManager.self)!)}
        .inObjectScope(.container)
        
        // Register ProgramManager with FirebaseProgramService
        // Scoped to `.container` to prevent multiple instances and maintain a single, shared reference across views
        container.register(ProgramManager.self){ r in ProgramManager(service: r.resolve(FirebaseProgramService.self)!)}
            .inObjectScope(.container)
    }
}

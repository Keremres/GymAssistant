//
//  ProgramManager.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 10.10.2024.
//

import Foundation

final class ProgramManager: ObservableObject{
    private let service: ProgramService
    
    @Published var program: Program? = nil
    
    init(service: ProgramService){
        self.service = service
    }
    
    /// Associates a user with a new program and updates the active program.
    /// - Parameters:
    ///   - userInfo: The user's information.
    ///   - program: The program to associate with the user.
    func useProgram(userInfo: UserInfo, program: Program) async throws {
        try await service.useProgram(userInfo: userInfo, program: program)
        DispatchQueue.main.async{
            self.program = program
        }
    }
    
    /// Publishes a new program to the backend.
    /// - Parameter program: The program to publish.
    func publishProgram(program: Program) async throws {
        try await service.publishProgram(program: program)
    }
    
    /// Retrieves the user's active program from the backend and sets it locally.
    /// - Parameter userInfo: The user's information.
    func getProgram(userInfo: UserInfo) async throws {
        let program = try await service.getProgram(userInfo: userInfo)
        DispatchQueue.main.async{
            self.program = program
        }
    }
    
    /// Fetches all available programs.
    /// - Returns: An array of available programs.
    func getPrograms() async throws -> [Program] {
        try await service.getPrograms()
    }
    
    /// Retrieves the user's program history.
    /// - Parameter userInfo: The user's information.
    /// - Returns: An array of the user's past programs.
    func getProgramHistory(userInfo: UserInfo) async throws -> [Program] {
        try await service.getProgramHistory(userInfo: userInfo)
    }
    
    /// Deletes a specific program from the user's program history.
    /// - Parameters:
    ///   - userInfo: The user's information.
    ///   - programId: The ID of the program to delete.
    func deleteProgramHistory(userInfo: UserInfo, programId: Program.ID) async throws {
        try await service.deleteUserProgramHistory(userInfo: userInfo, programId: programId)
        if self.program?.id == programId{
            DispatchQueue.main.async{
                self.program = nil
            }
        }
    }
    
    /// Starts a new week for the user's current program and updates it locally.
    /// - Parameter userInfo: The user's information.
    func newWeek(userInfo: UserInfo) async throws {
        guard let program = self.program else { return }
        let newProgram = try await service.newWeek(userInfo: userInfo, program: program)
        DispatchQueue.main.async{
            self.program = newProgram
        }
    }
    
    /// Saves a specific day of the program.
    /// - Parameters:
    ///   - userInfo: The user's information.
    ///   - dayModel: The model representing the day to save.
    func saveDay(userInfo: UserInfo, dayModel: DayModel) async throws {
        guard let program = self.program else { return }
        let newProgram = try await service.saveDay(userInfo: userInfo, dayModel: dayModel, program: program)
        DispatchQueue.main.async{
            self.program = newProgram
        }
    }
    
    /// Calculates chart data for a specific exercise based on the program data.
    /// - Parameter exerciseId: The ID of the exercise to calculate data for.
    /// - Returns: An array of `ChartModel` representing the data for chart visualization.
    func chartCalculator(exerciseId: Exercises.ID) -> [ChartModel] {
        guard let program = self.program else { return [] }
        return service.chartCalculator(exerciseId: exerciseId, program: program)
    }
    
    /// Clears the currently active program from memory.
    func programClear() {
        DispatchQueue.main.async{
            self.program = nil
        }
    }
}

//
//  ProgramManager.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 10.10.2024.
//

import Foundation

@MainActor
final class ProgramManager: ObservableObject{
    private let service: ProgramService
    
    @Published var program: Program? = nil
    
    init(service: ProgramService){
        self.service = service
    }
    
    func useProgram(userInfo: UserInfo, program: Program) async throws {
        try await service.useProgram(userInfo: userInfo, program: program)
        self.program = program
    }
    
    func publishProgram(program: Program) async throws {
        try await service.publishProgram(program: program)
    }
    
    func getProgram(userInfo: UserInfo) async throws {
        self.program = try await service.getProgram(userInfo: userInfo)
    }
    
    func getPrograms() async throws -> [Program] {
        try await service.getPrograms()
    }
    
    func getProgramHistory(userInfo: UserInfo) async throws -> [Program] {
        try await service.getProgramHistory(userInfo: userInfo)
    }
    
    func deleteProgramHistory(userInfo: UserInfo, programId: Program.ID) async throws {
        try await service.deleteUserProgramHistory(userInfo: userInfo, programId: programId)
        if self.program?.id == programId{
            self.program = nil
        }
    }
    
    func newWeek(userInfo: UserInfo) async throws {
        guard let program = self.program else { return }
        self.program = try await service.newWeek(userInfo: userInfo, program: program)
    }
    
    func saveDay(userInfo: UserInfo, dayModel: DayModel) async throws {
        guard let program = self.program else { return }
        self.program = try await service.saveDay(userInfo: userInfo, dayModel: dayModel, program: program)
    }
    
    func chartCalculator(exerciseId: Exercises.ID) -> [ChartModel] {
        guard let program = self.program else { return [] }
        return service.chartCalculator(exerciseId: exerciseId, program: program)
    }
    
    func programClear() {
        self.program = nil
    }
}

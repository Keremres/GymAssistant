//
//  ProgramService.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 11.10.2024.
//

import Foundation

protocol ProgramService {
    func useProgram(userInfo: UserInfo, program: Program) async throws
    func publishProgram(program: Program) async throws
    func getProgram(userInfo: UserInfo) async throws -> Program
    func getPrograms() async throws -> [Program]
    func getProgramHistory(userInfo: UserInfo) async throws -> [Program]
    func deleteUserProgramHistory(userInfo: UserInfo, programId: Program.ID) async throws
    func newWeek(userInfo: UserInfo, program: Program) async throws -> Program
    func saveDay(userInfo: UserInfo, dayModel: DayModel, program: Program) async throws -> Program
    func chartCalculator(exerciseId: Exercises.ID, program: Program) -> [ChartModel]
}

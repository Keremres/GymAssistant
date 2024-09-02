//
//  DayModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 31.07.2024.
//

import Foundation

struct Program: Identifiable, Hashable, Codable {
    let id: String
    var programName: String
    var programClass: String
    var week: [WeekModel]
    
    init(id: String = UUID().uuidString, programName: String, programClass: String, week: [WeekModel]) {
            self.id = id
            self.programName = programName
            self.programClass = programClass
            self.week = week
        }
}

struct WeekModel: Identifiable, Hashable, Codable {
    let id: String
    var date: Date
    var day: [DayModel]
    
    init(id: String = UUID().uuidString, date: Date = Date(), day: [DayModel]) {
            self.id = id
            self.date = date
            self.day = day
        }
}

struct DayModel: Identifiable, Hashable, Codable {
    let id: String
    var day: String
    var exercises: [Exercises]
    
    init(id: String = UUID().uuidString, day: String, exercises: [Exercises]) {
            self.id = id
            self.day = day
            self.exercises = exercises
        }
}

struct Exercises: Identifiable, Hashable, Codable {
    var id: String
    var exercise: String
    var set: Int
    var againStart: Int
    var again: Int
    var againEnd: Int
    var weight: Double
    var date: Date
    
    init(id: String = UUID().uuidString, exercise: String, set: Int = 0, againStart: Int = 0, again: Int = 0, againEnd: Int = 0, weight: Double = 0.0, date: Date = Date()) {
            self.id = id
            self.exercise = exercise
            self.set = set
            self.againStart = againStart
            self.again = again
            self.againEnd = againEnd
            self.weight = weight
            self.date = date
        }
}

extension Program{
    static var MOCK_PROGRAM : Program = .init(programName: "3x5", programClass: "Powerlifting", week: [WeekModel(day: DayModel.MOCK_DAY)])
}

extension DayModel{
    static var MOCK_DAY : [DayModel] = [
        .init(day: "Monday", exercises:
                .init(arrayLiteral: Exercises(exercise: "Squat", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 70),
                      Exercises(exercise: "Squat Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 62),
                      Exercises(exercise: "Bench Press", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 60),
                      Exercises(exercise: "Bench Press Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 22.5),
                      Exercises(exercise: "Pendlay Row", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 90),
                      Exercises(exercise: "Row Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 38.5))),
        .init(id: UUID().uuidString, day: "çarşamba", exercises:
                .init(arrayLiteral: Exercises(exercise: "Front Squat", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 70),
                      Exercises(exercise: "Squat Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 62),
                      Exercises(exercise: "Overhead Press", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 60),
                      Exercises(exercise: "Overhead Press Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 22.5),
                      Exercises(exercise: "Bench Press Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 22.5),
                      Exercises(exercise: "Deadlift", set: 1, againStart: 5, again: 5, againEnd: 0, weight: 90),
                      Exercises(exercise: "Deadlift Asistanı", set: 3, againStart: 5, again: 5, againEnd: 12, weight: 38.5))),
        .init(id: UUID().uuidString, day: "cuma", exercises:
                .init(arrayLiteral: Exercises(exercise: "Squat", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 70),
                      Exercises(exercise: "Squat Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 62),
                      Exercises(exercise: "Bench Press", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 60),
                      Exercises(exercise: "Bench Press Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 22.5),
                      Exercises(exercise: "Pendlay Row", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 90),
                      Exercises(exercise: "Row Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 38.5)))
    ]
}

extension Exercises{
    static var exerciseList: [Exercises] = [
        .init(exercise: "Squat"),
        .init(exercise: "Squat Assistant"),
        .init(exercise: "Front Squat"),
        .init(exercise: "Leg Extension"),
        .init(exercise: "Calf Raise"),
        .init(exercise: "Lunge"),
        .init(exercise: "Leg Press"),
        .init(exercise: "Leg Curl"),
        .init(exercise: "Hip Thrust"),
        
        .init(exercise: "Bench Press"),
        .init(exercise: "Bench Press Assistant"),
        .init(exercise: "Paused Bench Press"),
        .init(exercise: "Incline Dumbbell Press"),
        .init(exercise: "Incline Bench Press"),
        .init(exercise: "Dumbbell Chest Press"),
        .init(exercise: "Machine Press"),
        .init(exercise: "Push Up"),
        .init(exercise: "Triceps"),
        .init(exercise: "Banded Bench Press"),
        .init(exercise: "Z Press"),
        .init(exercise: "Dips"),
        .init(exercise: "Cable Cross"),
        
        .init(exercise: "Overhead Press"),
        .init(exercise: "Overhead Press Assistant"),
        .init(exercise: "Machine Vertical Press"),
        .init(exercise: "Landmine Press"),
        .init(exercise: "Dumbbell Lateral Raise"),
        .init(exercise: "Lateral Reise"),
        .init(exercise: "Facepull"),
        .init(exercise: "Pecdec"),
        .init(exercise: "Rear Delt"),
        
        .init(exercise: "Pull Up"),
        .init(exercise: "Pull Down"),
        .init(exercise: "Bentover Row"),
        .init(exercise: "Pendlay Row"),
        .init(exercise: "Row Assistant"),
        .init(exercise: "Lat Pulldown"),
        .init(exercise: "Machine Row"),
        .init(exercise: "Seated Row"),
        .init(exercise: "T Bar Row"),
        .init(exercise: "Power Shrug"),
        .init(exercise: "Farmers Carry"),
        .init(exercise: "Hammer Curl"),
        .init(exercise: "Biceps"),
        .init(exercise: "Cable Row"),
        
        .init(exercise: "Deadlift"),
        .init(exercise: "Deadlift Assistant"),
        .init(exercise: "Romanian Deadlift"),
        .init(exercise: "Sumo Deadlift"),
        .init(exercise: "Rack Pull"),
        .init(exercise: "Banded Deadlift"),
        .init(exercise: "Deficit Deadlift"),
        .init(exercise: "Shrug"),
        .init(exercise: "Plank"),
    ]
}

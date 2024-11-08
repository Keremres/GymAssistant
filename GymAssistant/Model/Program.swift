//
//  DayModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 31.07.2024.
//

import Foundation

struct Program: Identifiable, Hashable, Codable, IdentifiableByString {
    let id: String
    var programName: String
    var programClass: String
    var week: [WeekModel]
    
    init(id: String = UUID().uuidString,
         programName: String,
         programClass: String,
         week: [WeekModel]) {
        self.id = id
        self.programName = programName
        self.programClass = programClass
        self.week = week
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.programName = try container.decode(String.self, forKey: .programName)
        self.programClass = try container.decode(String.self, forKey: .programClass)
        self.week = try container.decode([WeekModel].self, forKey: .week)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.programName, forKey: .programName)
        try container.encode(self.programClass, forKey: .programClass)
        try container.encode(self.week, forKey: .week)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, week
        case programName = "program_name"
        case programClass = "program_class"
    }
}

struct WeekModel: Identifiable, Hashable, Codable {
    let id: String
    var date: Date
    var day: [DayModel]
    
    init(id: String = UUID().uuidString,
         date: Date = Date(),
         day: [DayModel]) {
        self.id = id
        self.date = date
        self.day = day
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.date = try container.decode(Date.self, forKey: .date)
        self.day = try container.decode([DayModel].self, forKey: .day)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.day, forKey: .day)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, day
    }
}

struct DayModel: Identifiable, Hashable, Codable {
    let id: String
    var day: String
    var exercises: [Exercises]
    
    init(id: String = UUID().uuidString,
         day: String,
         exercises: [Exercises]) {
        self.id = id
        self.day = day
        self.exercises = exercises
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.day = try container.decode(String.self, forKey: .day)
        self.exercises = try container.decode([Exercises].self, forKey: .exercises)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.day, forKey: .day)
        try container.encode(self.exercises, forKey: .exercises)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, day, exercises
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
    
    init(id: String = UUID().uuidString,
         exercise: String,
         set: Int = 0,
         againStart: Int = 0,
         again: Int = 0,
         againEnd: Int = 0,
         weight: Double = 0.0,
         date: Date = Date()) {
        self.id = id
        self.exercise = exercise
        self.set = set
        self.againStart = againStart
        self.again = again
        self.againEnd = againEnd
        self.weight = weight
        self.date = date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.exercise = try container.decode(String.self, forKey: .exercise)
        self.set = try container.decode(Int.self, forKey: .set)
        self.againStart = try container.decode(Int.self, forKey: .againStart)
        self.again = try container.decode(Int.self, forKey: .again)
        self.againEnd = try container.decode(Int.self, forKey: .againEnd)
        self.weight = try container.decode(Double.self, forKey: .weight)
        self.date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.exercise, forKey: .exercise)
        try container.encode(self.set, forKey: .set)
        try container.encode(self.againStart, forKey: .againStart)
        try container.encode(self.again, forKey: .again)
        try container.encode(self.againEnd, forKey: .againEnd)
        try container.encode(self.weight, forKey: .weight)
        try container.encode(self.date, forKey: .date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, exercise, set, again, weight, date
        case againStart = "again_start"
        case againEnd = "again_end"
    }
}

extension Program{
    static var MOCK_PROGRAM: Program = .init(programName: "3x5",
                                             programClass: "Powerlifting",
                                             week: [WeekModel(day: DayModel.MOCK_DAY)])
    
    static func baseProgram() -> Program {
        return Program(id: UUID().uuidString,
                       programName: "",
                       programClass: "Powerlifting",
                       week: [WeekModel.baseWeek()])
    }
}

extension WeekModel{
    static func baseWeek() -> WeekModel {
        return WeekModel(id: UUID().uuidString,
                         date: Date(),
                         day: [DayModel.baseDay()])
    }
}

extension DayModel{
    
    static func baseDay() -> DayModel {
        return DayModel(id: UUID().uuidString,
                        day: "Monday",
                        exercises: [Exercises.exerciseList[0]])
    }
    
    static var MOCK_DAY: [DayModel] = [
        .init(day: "Monday", exercises:
                .init(arrayLiteral: Exercises(exercise: "Squat", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 70),
                      Exercises(exercise: "Squat Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 62),
                      Exercises(exercise: "Bench Press", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 60),
                      Exercises(exercise: "Bench Press Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 22.5),
                      Exercises(exercise: "Pendlay Row", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 90),
                      Exercises(exercise: "Row Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 38.5))),
        .init(id: UUID().uuidString, day: "Wednesday", exercises:
                .init(arrayLiteral: Exercises(exercise: "Front Squat", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 70),
                      Exercises(exercise: "Squat Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 62),
                      Exercises(exercise: "Overhead Press", set: 3, againStart: 5, again: 5, againEnd: 0, weight: 60),
                      Exercises(exercise: "Overhead Press Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 22.5),
                      Exercises(exercise: "Bench Press Asistanı", set: 3, againStart: 8, again: 8, againEnd: 12, weight: 22.5),
                      Exercises(exercise: "Deadlift", set: 1, againStart: 5, again: 5, againEnd: 0, weight: 90),
                      Exercises(exercise: "Deadlift Asistanı", set: 3, againStart: 5, again: 5, againEnd: 12, weight: 38.5))),
        .init(id: UUID().uuidString, day: "Friday", exercises:
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

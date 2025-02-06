//
//  GymAssistantWidget.swift
//  GymAssistantWidget
//
//  Created by Kerem RESNENLİ on 29.08.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    @AppStorage("goal", store: UserDefaults(suiteName: "group.com.keremresnenli.GymAssistant")) private var goal: Data = Data()
    
    func placeholder(in context: Context) -> GymAssistantEntry {
        if let goal = try? JSONDecoder().decode(Goal.self, from: self.goal){
            return GymAssistantEntry(date: Date(), goal: goal)
        } else {
            return GymAssistantEntry()
        }
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GymAssistantEntry) -> ()) {
        Task {
            if let goal = try? JSONDecoder().decode(Goal.self, from: self.goal),
               let goalState = try? await fetchData(){
                let entry = GymAssistantEntry(date: Date(), goal: goal, goalState: goalState)
                completion(entry)
            } else {
                let entry = GymAssistantEntry()
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        Task {
            if let goal = try? JSONDecoder().decode(Goal.self, from: self.goal),
               let goalState = try? await fetchData(){
                let entry = GymAssistantEntry(date: currentDate, goal: goal, goalState: goalState)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }
    
    func fetchData() async throws -> Goal {
        let healthManager: HealthProtocol = HealthManager()
        var goalState: Goal = .init(stepsGoal: 0, caloriesGoal: 0)
        
        await withCheckedContinuation { continuation in
            healthManager.fetchTodaySteps {
                goalState.stepsGoal = $0
                continuation.resume()
            }
        }
        
        await withCheckedContinuation { continuation in
            healthManager.fetchTodayCalories {
                goalState.caloriesGoal = $0
                continuation.resume()
            }
        }
        
        return goalState
    }
}

struct GymAssistantEntry: TimelineEntry {
    var date: Date = .now
    var goal: Goal = .init(stepsGoal: 0, caloriesGoal: 0)
    var goalState: Goal = .init(stepsGoal: 0, caloriesGoal: 0)
}

struct GymAssistantWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryRectangular:
            if #available(iOS 17.0, *) {
                Button(intent: RefreshIntent()) {
                    accessoryRectangular
                }
                .buttonStyle(.plain)
            } else {
                accessoryRectangular
            }
        case .systemSmall:
            if #available(iOS 17.0, *) {
                Button(intent: RefreshIntent()) {
                    systemSmall
                }
                .buttonStyle(.plain)
            } else {
                systemSmall
            }
        case .systemMedium:
            if #available(iOS 17.0, *) {
                Button(intent: RefreshIntent()) {
                    systemMedium
                }
                .buttonStyle(.plain)
            } else {
                systemMedium
            }
//        case .systemLarge:
//            if #available(iOS 17.0, *) {
//                Button(intent: RefreshIntent()) {
//                    systemLarge
//                }
//                .buttonStyle(.plain)
//            } else {
//                systemLarge
//            }
        default:
            if #available(iOS 17.0, *) {
                Button(intent: RefreshIntent()) {
                    accessoryRectangular
                }
                .buttonStyle(.plain)
            } else {
                accessoryRectangular
            }
        }
    }
}

struct GymAssistantWidget: Widget {
    let kind: String = "GymAssistantWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                GymAssistantWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                GymAssistantWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
        .configurationDisplayName(LocalizedStringKey("Daily Activity Widget"))
        .description(LocaleKeys.Widget.description.localized.replacingOccurrences(of: "\\n", with: "\n"))
    }
}

#Preview(as: .systemSmall) {
    GymAssistantWidget()
} timeline: {
    GymAssistantEntry(date: .now, goal: .init(stepsGoal: 10000, caloriesGoal: 400), goalState: .init(stepsGoal: 7508, caloriesGoal: 251))
}

#Preview(as: .systemMedium) {
    GymAssistantWidget()
} timeline: {
    GymAssistantEntry(date: .now, goal: .init(stepsGoal: 10000, caloriesGoal: 400), goalState: .init(stepsGoal: 7508, caloriesGoal: 251))
}

//#Preview(as: .systemLarge) {
//    GymAssistantWidget()
//} timeline: {
//    GymAssistantEntry(date: .now, goal: .init(stepsGoal: 10000, caloriesGoal: 400), goalState: .init(stepsGoal: 7508, caloriesGoal: 251))
//}

#Preview(as: .accessoryRectangular) {
    GymAssistantWidget()
} timeline: {
    GymAssistantEntry(date: .now, goal: .init(stepsGoal: 10000, caloriesGoal: 400), goalState: .init(stepsGoal: 7508, caloriesGoal: 251))
}

extension GymAssistantWidgetEntryView {
    private var systemSmall: some View {
        ZStack {
            ZStack {
                progressCircle(progress: entry.goalState.stepsGoal, goal: entry.goal.stepsGoal, color: .blue, width: 10)
                progressCircle(progress: entry.goalState.caloriesGoal, goal: entry.goal.caloriesGoal, color: .red, width: 10)
                    .padding(.all, 10)
            }
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: SystemImage.figureWalk)
                    Text("\(entry.goal.stepsGoal) : \(entry.goalState.stepsGoal)")
                }
                HStack {
                    Image(systemName: SystemImage.flame)
                    Text("\(entry.goal.caloriesGoal) : \(entry.goalState.caloriesGoal)")
                }
            }
        }
    }
    
    private var systemMedium: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: SystemImage.figureWalk)
                    Text("\(entry.goal.stepsGoal) : \(entry.goalState.stepsGoal)")
                }
                HStack {
                    Image(systemName: SystemImage.flame)
                    Text("\(entry.goal.caloriesGoal) : \(entry.goalState.caloriesGoal)")
                }
            }
            ZStack {
                progressCircle(progress: entry.goalState.stepsGoal, goal: entry.goal.stepsGoal, color: .blue, width: 10)
                progressCircle(progress: entry.goalState.caloriesGoal, goal: entry.goal.caloriesGoal, color: .red, width: 10)
                    .padding(.all, 10)
            }
        }
    }
    
//    private var systemLarge: some View {
//        HStack {
//            VStack {
//                HStack {
//                    Image(systemName: "figure.walk")
//                    Text("\(entry.goal.stepsGoal) : \(entry.goalState.stepsGoal)")
//                }
//                HStack {
//                    Image(systemName: "flame")
//                    Text("\(entry.goal.caloriesGoal) : \(entry.goalState.caloriesGoal)")
//                }
//            }
//            ZStack {
//                progressCircle(progress: entry.goalState.stepsGoal, goal: entry.goal.stepsGoal, color: .blue, width: 10)
//                progressCircle(progress: entry.goalState.caloriesGoal, goal: entry.goal.caloriesGoal, color: .red, width: 10)
//                    .padding(.all, 10)
//            }
//        }
//    }
    
    private var accessoryRectangular: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: SystemImage.figureWalk)
                Text("\(entry.goal.stepsGoal) : \(entry.goalState.stepsGoal)")
            }
            HStack {
                Image(systemName: SystemImage.flame)
                Text("\(entry.goal.caloriesGoal) : \(entry.goalState.caloriesGoal)")
            }
        }
    }
}

extension GymAssistantWidgetEntryView {
    private func progressCircle(progress: Int, goal: Int, color: Color, width: CGFloat) -> some View {
        ZStack{
            Circle()
                .stroke(color.opacity(0.3), lineWidth: width)
            Circle()
                .trim(from: 0, to: CGFloat(progress) / CGFloat(goal))
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(radius: 5)
        }
        .padding(.all, width / 2)
    }
}

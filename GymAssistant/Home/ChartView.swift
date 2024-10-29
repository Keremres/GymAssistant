//
//  ChartView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 3.08.2024.
//

import SwiftUI
import Charts

struct ChartView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var programManager: ProgramManager
    @State var exercise: Exercises
    @State private var rawSelectedDate: Date? = nil
    
    var body: some View {
        NavigationStack{
            chart
        }
        .navigationTitle("\(exercise.exercise)")
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .bold()
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
    }
    @ViewBuilder
    var selectionPopover: some View{
        if let rawSelectedDate,
           let selectedData = programManager.chartCalculator(exerciseId: exercise.id).first(where: { Calendar.current.isDate($0.date, inSameDayAs: rawSelectedDate) }) {
            VStack {
                Text("Date: \(selectedData.date.formatted())")
                Text("Weight: \(selectedData.value, specifier: "%.2f") kg")
            }
            .padding()
            .foregroundStyle(.tabBar)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 4)
        }
    }
}

#Preview {
    NavigationStack{
        ChartView(exercise: DayModel.MOCK_DAY[0].exercises[0])
            .environmentObject(ProgramManager(service: FirebaseProgramService()))
    }
}

extension ChartView {
    
    private var chart: some View {
        Chart{
            ForEach(programManager.chartCalculator(exerciseId: exercise.id), id: \.self) { chartData in
                if (programManager.program?.week.count != 1){
                    LineMark(
                        x: .value("Date", chartData.date, unit: .day),
                        y: .value("Weight", chartData.value)
                    )
                    .interpolationMethod(.catmullRom)
                    if let rawSelectedDate{
                        RuleMark(x: .value("Selected Date", rawSelectedDate, unit: .day))
                            .foregroundStyle(.gray.opacity(0.3))
                            .zIndex(-1)
                            .annotation(position: .top, spacing: 5, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)){
                                selectionPopover
                            }
                    }
                }else{
                    PointMark(
                        x: .value("Date", chartData.date, unit: .day),
                        y: .value("Weight", chartData.value)
                    )
                    if let rawSelectedDate{
                        RuleMark(x: .value("Selected Date", rawSelectedDate, unit: .day))
                            .foregroundStyle(.gray.opacity(0.3))
                            .zIndex(-1)
                            .annotation(position: .top, spacing: 5, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)){
                                selectionPopover
                            }
                    }
                }
            }
        }
        .chartXSelection(value: $rawSelectedDate)
        .frame(height: UIScreen.main.bounds.height * 0.4)
        .padding(16)
    }
}

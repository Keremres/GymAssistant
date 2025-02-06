//
//  ChartView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 3.08.2024.
//

import SwiftUI
import Charts

struct ChartView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var programManager: ProgramManager
    @State var exercise: Exercises
    @State private var rawSelectedDate: Date? = nil
    
    var body: some View {
        NavigationStack{
            chart
        }
        .navigationTitle("\(exercise.exercise)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                dismissButton
            }
        }
    }
}

#Preview {
    NavigationStack{
        ChartView(exercise: DayModel.MOCK_DAY[0].exercises[0])
            .environmentObject(AppContainer.shared.programManager)
    }
}

extension ChartView {
    
    private var chart: some View {
        Chart{
            ForEach(programManager.chartCalculator(exerciseId: exercise.id), id: \.self) { chartData in
                if (programManager.program?.week.count != 1){
                    LineMark(
                        x: .value(LocaleKeys.Home.date.localized, chartData.date, unit: .day),
                        y: .value(LocaleKeys.Home.weight.localized, chartData.value)
                    )
                    .interpolationMethod(.catmullRom)
                    if let rawSelectedDate{
                        RuleMark(x: .value(LocaleKeys.Home.selectDate.localized, rawSelectedDate, unit: .day))
                            .foregroundStyle(.gray.opacity(0.3))
                            .zIndex(-1)
                            .annotation(position: .top, spacing: 5, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)){
                                selectionPopover
                            }
                    }
                }else{
                    PointMark(
                        x: .value(LocaleKeys.Home.date.localized, chartData.date, unit: .day),
                        y: .value(LocaleKeys.Home.date.localized, chartData.value)
                    )
                    if let rawSelectedDate{
                        RuleMark(x: .value(LocaleKeys.Home.selectDate.localized, rawSelectedDate, unit: .day))
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
    
    @ViewBuilder
    private var selectionPopover: some View{
        if let rawSelectedDate,
           let selectedData = programManager.chartCalculator(exerciseId: exercise.id).first(where: { Calendar.current.isDate($0.date, inSameDayAs: rawSelectedDate) }) {
            VStack {
                Text("\(LocaleKeys.Home.date.localized): \(selectedData.date.formatted())")
                Text("\(LocaleKeys.Home.date.localized): \(selectedData.value, specifier: "%.2f") kg")
            }
            .padding()
            .foregroundStyle(.tabBar)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 4)
        }
    }
    
    private var dismissButton: some View {
        Image(systemName: SystemImage.chevronLeft)
            .imageScale(.large)
            .bold()
            .frame(width: 44, height: 44)
            .background {
                Color.background.opacity(0.0001)
            }
            .onTapGesture {
                withAnimation{
                    dismiss()
                }
            }
    }
}

//
//  ProgramBoxView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 26.08.2024.
//

import SwiftUI

struct ProgramBoxView: View {
    let program: Program
    var body: some View {
        ScrollView{
            VStack{
                HStack {
                    Text("\(program.programName)")
                    Spacer()
                    Text("\(program.programClass)")
                }
                .foregroundStyle(.pink)
                ForEach(program.week[0].day){ day in
                    DayGroupBox(dayModel: day, change: false)
                }
            }
        }.frame(height: UIScreen.main.bounds.height * 0.225)
    }
}

#Preview {
    ProgramBoxView(program: Program.MOCK_PROGRAM)
}

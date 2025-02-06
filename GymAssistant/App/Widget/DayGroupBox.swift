//
//  SwiftUIView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 31.07.2024.
//

import SwiftUI

struct DayGroupBox: View {
    var dayModel: DayModel
    let change: Bool
    var body: some View {
        GroupBox {
            GroupBox{
                VStack {
                    if change{
                        ForEach(dayModel.exercises.indices, id: \.self) { index in
                            Text("\(dayModel.exercises[index].exercise) : \(dayModel.exercises[index].set) x \(dayModel.exercises[index].again) = \( dayModel.exercises[index].weight, specifier: "%.2f")")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.tabBar)
                            Divider()
                        }
                    } else {
                        ForEach(dayModel.exercises.indices, id: \.self) { index in
                            Text("\(dayModel.exercises[index].exercise) : \(dayModel.exercises[index].set) x \(dayModel.exercises[index].againStart)\(dayModel.exercises[index].againEnd > dayModel.exercises[index].againStart ? " - \(dayModel.exercises[index].againEnd)": "")")
                            Divider()
                        }
                        .font(.title3)
                        .bold()
                        .foregroundColor(.tabBar)
                    }
                }
            }
        }label: {
            Text(LocalizedStringKey(dayModel.day)).foregroundStyle(.pink)
        }
    }
}

#Preview {
    DayGroupBox(dayModel: DayModel.MOCK_DAY[0], change: false)
}

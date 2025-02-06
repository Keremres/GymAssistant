//
//  GoalSettingView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 26.01.2025.
//

import SwiftUI

struct GoalSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = GoalSettingViewModel()
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        main
    }
}

#Preview {
    GoalSettingView()
}

extension GoalSettingView {
    private var main: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: SystemImage.figureWalk)
                Text("\(LocaleKeys.Home.stepsGoal.localized) : ")
                TextField(LocaleKeys.Home.goalEnter.localized, text: $viewModel.stepsGoal)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .stepsGoal)
            }
            HStack {
                Image(systemName: SystemImage.flame)
                Text("\(LocaleKeys.Home.caloriesGoal.localized) : ")
                TextField(LocaleKeys.Home.goalEnter.localized, text: $viewModel.caloriesGoal)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .caloriesGoal)
            }
            HStack{
                Spacer()
                BaseButton(onTab: {
                    viewModel.save()
                    dismiss()
                }, title: LocaleKeys.Dialog.save.localized)
                Spacer()
            }
        }
        .padding()
        .background(Color.tabBarText.opacity(0.0001).ignoresSafeArea(.all))
        .onTapGesture {
            focusedField = nil
        }
    }
}

extension GoalSettingView {
    private enum FocusedField: Int ,Hashable, CaseIterable {
        case stepsGoal
        case caloriesGoal
    }
}

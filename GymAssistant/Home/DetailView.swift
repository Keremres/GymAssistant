//
//  DetailView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import SwiftUI
import Charts

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel = DetailViewModel()
    @State var dayModel: DayModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            ScrollView{
                ForEach($dayModel.exercises){ $exercises in
                    DetailStepper(exercise: $exercises)
                }
                .padding(.horizontal,16)
                BaseButton(onTab: {
                    viewModel.saveDay(dayModel: dayModel)
                    dismiss()
                }, title: DialogText.save)
                .padding(.top, 16)
            }
        }
        .navigationTitle("\(dayModel.day)")
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                dismissButton
            }
        }
    }
}

#Preview {
    NavigationStack{
        DetailView(dayModel: DayModel.MOCK_DAY[0])
    }
}

extension DetailView {
    private var dismissButton: some View {
        Image(systemName: SystemImage.chevronLeft)
            .imageScale(.large)
            .bold()
            .onTapGesture {
                withAnimation{
                    dismiss()
                }
            }
    }
}

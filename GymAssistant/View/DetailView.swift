//
//  DetailView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import SwiftUI
import Charts

struct DetailView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @State var dayModel: DayModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            ScrollView{
                ForEach($dayModel.exercises){ $exercises in
                        DetailStepper(exercise: $exercises)
                }.padding(.horizontal,16)
                BaseButton(onTab: {
                    Task{
                        try await homeViewModel.saveDay(user: mainTabViewModel.user,dayModel: dayModel)
                        dismiss()
                    }
                }, title: "Save")
                    .padding(.top, 16)
            }
        }.navigationTitle("\(dayModel.day)")
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
}

#Preview {
    NavigationStack{
        DetailView(dayModel: DayModel.MOCK_DAY[0])
            .environmentObject(HomeViewModel())
            .environmentObject(MainTabViewModel(user: User.MOCK_USER))
    }
}

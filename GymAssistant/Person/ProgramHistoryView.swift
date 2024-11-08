//
//  ProgramHistory.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 24.08.2024.
//

import SwiftUI

struct ProgramHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ProgramHistoryViewModel = ProgramHistoryViewModel()
    
    var body: some View {
        NavigationStack {
            if !viewModel.programHistory.isEmpty {
                programHistoryCard
            } else {
                emptyHistory
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                dismissButton
            }
        }
        .showAlert(alert: $viewModel.alert)
    }
}

#Preview {
    NavigationStack{
        ProgramHistoryView()
    }
}

extension ProgramHistoryView {
    private var programHistoryCard: some View {
        List {
            ForEach(viewModel.programHistory) { program in
                ProgramBoxView(program: program)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task{
                                await viewModel.programDelete(program: program)
                            }
                        } label: {
                            Label("Delete", systemImage: SystemImage.trash)
                                .symbolVariant(.fill)
                        }
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyHistory: some View {
        ContentUnavailableView(
            label: {
                Label("No Program History Found", systemImage: SystemImage.trayFill)
            },
            description: {
                Text("You don't have any program history")
            }
        )
    }
    
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

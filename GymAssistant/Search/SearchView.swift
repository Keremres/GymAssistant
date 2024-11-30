//
//  SearchView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            searchList
                .searchable(text: $viewModel.text, prompt: "Search...")
        }
        .showAlert(alert: $viewModel.alert)
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
}

#Preview {
    NavigationStack{
        SearchView()
    }
}

extension SearchView {
    private var searchList: some View {
        List{
            ForEach(viewModel.programs.filter { program in
                viewModel.text.isEmpty || program.programName.localizedCaseInsensitiveContains(viewModel.text)
            }, id: \.id) { program in
                NavigationLink(destination: SearchDetailView(searchViewModel: viewModel, program: program)
                    .navigationBarBackButtonHidden(true)){
                        Text(program.programName)
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
}

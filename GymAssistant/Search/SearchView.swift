//
//  SearchView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    
    init(programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(programManager: programManager, userManager: userManager))
    }
    
    var body: some View {
        NavigationStack {
            searchList
                .searchable(text: $viewModel.text, prompt: LocaleKeys.Search.searchText.localized)
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

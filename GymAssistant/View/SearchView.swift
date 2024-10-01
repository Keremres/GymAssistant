//
//  SearchView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel = SearchViewModel()
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @State var text = ""
    var body: some View {
        NavigationStack {
            List{
                ForEach(viewModel.programs.filter { program in
                    text.isEmpty || program.programName.localizedCaseInsensitiveContains(text)
                }, id: \.id) { program in
                    NavigationLink(destination: SearchDetailView(searchViewModel: viewModel, program: program)
                        .navigationBarBackButtonHidden(true)){
                        Text(program.programName)
                    }
                }
            }.searchable(text: $text, prompt: "arama...")
        }
        .showAlert(alert: $viewModel.alert)
    }
}

#Preview {
    SearchView()
        .environmentObject(MainTabViewModel(user: User.MOCK_USER))
}

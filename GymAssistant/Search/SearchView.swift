//
//  SearchView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var programManager: ProgramManager
    @StateObject var viewModel: SearchViewModel
    @State var text = ""
    
    init(programManager: ProgramManager, userManager: UserManager) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(programManager: programManager,
                                                               userManager: userManager))
    }
    
    var body: some View {
        NavigationStack {
            searchList
            .searchable(text: $text, prompt: "arama...")
        }
        .showAlert(alert: $viewModel.alert)
    }
}

#Preview {
    let authManager = AuthManager(service: FirebaseAuthService())
    let programManager = ProgramManager(service: FirebaseProgramService())
    let userManager = UserManager(service: FirebaseUserService(), authManager: authManager)
    NavigationStack{
        SearchView(programManager: programManager, userManager: userManager)
            .environmentObject(userManager)
            .environmentObject(programManager)
    }
}

extension SearchView {
    private var searchList: some View {
        List{
            ForEach(viewModel.programs.filter { program in
                text.isEmpty || program.programName.localizedCaseInsensitiveContains(text)
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

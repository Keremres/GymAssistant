//
//  RegisterView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack{
                BaseTextField(textTitle: RegisterText.userName, textField: $viewModel.username)
                BaseTextField(textTitle: RegisterText.email, textField: $viewModel.email).padding(Edge.Set.top,16)
                BaseSecureField(textTitle: RegisterText.password, textField: $viewModel.password).padding(Edge.Set.top,16)
                BaseSecureField(textTitle: RegisterText.verifyPassword, textField: $viewModel.verifyPassword).padding(Edge.Set.top,16)
                BaseButton(onTab:{
                    Task{
                        try await viewModel.createUser()
                    }
                }, title: RegisterText.signUp).padding(Edge.Set.top,16)
                    .showAlert(alert: $viewModel.alert)
                
            }.padding(16)
        }.toolbar{
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
        RegisterView()
    }
}

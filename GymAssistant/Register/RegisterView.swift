//
//  RegisterView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel
    @Environment(\.dismiss) var dismiss
    
    init(authManager: AuthManager) {
        _viewModel = StateObject(wrappedValue: RegisterViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                BaseTextField(textTitle: RegisterText.firstName,
                              textField: $viewModel.register.firstName)
                BaseTextField(textTitle: RegisterText.lastName,
                              textField: $viewModel.register.lastName)
                .padding(.top, 16)
                BaseTextField(textTitle: RegisterText.email,
                              textField: $viewModel.register.email)
                .padding(.top, 16)
                BaseSecureField(textTitle: RegisterText.password,
                                textField: $viewModel.register.password)
                .padding(.top, 16)
                BaseSecureField(textTitle: RegisterText.verifyPassword,
                                textField: $viewModel.register.verifyPassword)
                .padding(.top, 16)
                signUpButton
            }
            .padding(16)
        }
        .navigationTitle(RegisterText.signUp)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                dismissButton
            }
        }
    }
}

#Preview {
    let authManager = AuthManager(service: FirebaseAuthService())
    NavigationStack{
        RegisterView(authManager: authManager)
    }
}

extension RegisterView {
    
    private var dismissButton: some View {
        Image(systemName: "chevron.left")
            .imageScale(.large)
            .bold()
            .onTapGesture {
                dismiss()
            }
    }
    
    private var signUpButton: some View {
        BaseButton(onTab:{
            Task{
                await viewModel.createUser()
            }
        }, title: RegisterText.signUp)
        .showAlert(alert: $viewModel.alert)
        .padding(.top, 16)
    }
}

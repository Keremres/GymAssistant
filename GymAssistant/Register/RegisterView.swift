//
//  RegisterView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
    NavigationStack{
        RegisterView()
    }
}

extension RegisterView {
    
    private var dismissButton: some View {
        Image(systemName: SystemImage.chevronLeft)
            .imageScale(.large)
            .bold()
            .onTapGesture {
                dismiss()
            }
    }
    
    private var signUpButton: some View {
        BaseButton(onTab:{
            viewModel.createUser()
        }, title: RegisterText.signUp)
        .showAlert(alert: $viewModel.alert)
        .padding(.top, 16)
    }
}

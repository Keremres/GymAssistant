//
//  ForgotPassword.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 13.08.2024.
//

import SwiftUI

struct ForgotPassword: View {
    @ObservedObject var viewModel: LoginViewModel
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        ZStack{
            Color.background
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    focusedField = nil
                }
            
            VStack{
                Text(LocaleKeys.Login.Forgot.resetPassword.localized)
                    .font(.title2)
                BaseTextField(textTitle: LocaleKeys.Login.Forgot.pleaseEmail.localized,
                              textField: $viewModel.forgotPassword)
                .focused($focusedField, equals: .email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .padding(.top, CGFloat(5))
                BaseButton(onTab: {
                    viewModel.resetPassword(email: viewModel.forgotPassword)
                }, title: LocaleKeys.Login.Forgot.resetPassword.localized)
                .padding(.top, CGFloat(10))
                .disabled(!viewModel.forgotPassword.contains("@") || !viewModel.forgotPassword.contains("."))
                .showAlert(alert: $viewModel.alert)
            }
            .padding(CGFloat(16))
        }
    }
}

#Preview {
    ForgotPassword(viewModel: LoginViewModel())
}

extension ForgotPassword {
    private enum FocusedField {
        case email
    }
}

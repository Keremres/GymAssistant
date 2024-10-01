//
//  ForgotPassword.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 13.08.2024.
//

import SwiftUI

struct ForgotPassword: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack{
            Text("Reset Password")
                .font(.title2)
            BaseTextField(textTitle: " Please enter your email", textField: $viewModel.forgotPassword)
                .padding(.top, CGFloat(5))
            BaseButton(onTab: {
                Task{
                    try await viewModel.resetPassword(email: viewModel.forgotPassword)
                }
            }, title: "Reset Password")
            .padding(.top, CGFloat(10))
            .disabled(!viewModel.forgotPassword.contains("@") || !viewModel.forgotPassword.contains("."))
            .showAlert(alert: $viewModel.alert)
        }.padding(CGFloat(16))
    }
}

#Preview {
    ForgotPassword(viewModel: LoginViewModel())
}

//
//  ErrorAlert.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 13.09.2024.
//

import Foundation
import SwiftUI

protocol ErrorAlert: Error, LocalizedError{
    var title: String { get }
    var subtitle: String? { get }
    var buttons: AnyView { get }
}

enum CustomError: ErrorAlert{
    case customError(title: String = "Error", subtitle: String = "", buttons: AnyView = AnyView(getButtonsForAlert()))
    case authError(appAuthError: AppAuthError)
    case errorAlert
    case error(error: Error)
    
    var title: String{
        switch self{
        case .customError(let title, _, _):
            return title
        case .authError(appAuthError: let appAuthError):
            return appAuthError.title
        case .errorAlert:
            return "Error"
        case .error:
            return "Error"
        }
    }
    var subtitle: String?{
        switch self{
        case .customError(_, let subtitle, _):
            return subtitle
        case .authError(appAuthError: let appAuthError):
            return appAuthError.subtitle
        case .errorAlert:
            return ""
        case .error(error: let error):
            return "Error: \(error.localizedDescription)"
        }
    }
    var buttons: AnyView{
        switch self{
        case .customError(_, _, let buttons):
            return buttons
        default:
            return AnyView(CustomError.getButtonsForAlert())
        }
    }
}

extension ErrorAlert{
    
    var buttons: AnyView{
        AnyView(Self.getButtonsForAlert())
    }
    
    @ViewBuilder
    static func getButtonsForAlert() -> some View {
        switch self {
        default:
            Button("Cancel", role: .cancel, action: {})
        }
    }
}

extension View {
    func showAlert<T: ErrorAlert>(alert: Binding<T?>) -> some View {
        self
            .alert(alert.wrappedValue?.title ?? "Error", isPresented: Binding(value: alert)){
                alert.wrappedValue?.buttons
            } message: {
                if let subtitle = alert.wrappedValue?.subtitle{
                    Text(subtitle)
                }
            }
    }
}

extension Binding where Value == Bool {
    
    init<T>(value: Binding<T?>) {
        self.init{
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}

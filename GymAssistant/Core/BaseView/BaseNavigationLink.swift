//
//  BaseNavigationLinkButton.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 22.08.2024.
//

import SwiftUI

struct BaseNavigationLink<Label: View, Destination: View>: View {
    var destination: Destination
    var title: String
    var label: (() -> Label)?
    
    init(destination: Destination, title: String, @ViewBuilder label: @escaping () -> Label = { EmptyView() }) {
        self.destination = destination
        self.title = title
        self.label = label
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                if let label = label {
                    label()
                }
                Text(title).foregroundColor(.tabBarText).font(.title2)
            }
        }
        .tint(.tabBar)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .controlSize(.large)
        .shadow(radius: 10)
        .padding(.horizontal, 5)
    }
}

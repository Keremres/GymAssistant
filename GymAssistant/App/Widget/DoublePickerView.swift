//
//  DoublePickerView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 29.08.2024.
//

//import SwiftUI
//
//struct DoublePickerView: View {
//    @State private var decimal = 0
//    @State private var percent: Double = 0
//    private let percents: [Double] =  [0, 0.25, 0.5, 0.75]
//    @Binding var result: Double
//    var body: some View {
//        HStack{
//            Picker("" ,selection: $decimal) {
//                ForEach(0...500, id: \.self){ i in
//                    Text("\(i)").tag(i)
//                }
//            }
//            .pickerStyle(.inline)
//            .frame(width: UIScreen.main.bounds.height * 0.06438, height: UIScreen.main.bounds.height * 0.1073)
//            Picker("" ,selection: $percent) {
//                ForEach(percents, id: \.self){ i in
//                    Text("\(i, specifier: "%0.2f")").tag(i)
//                }
//            }
//            .pickerStyle(.inline)
//            .frame(width: UIScreen.main.bounds.height * 0.07511, height: UIScreen.main.bounds.height * 0.1073)
//        }
//        .onChange(of: decimal){
//            result = Double(decimal) + percent
//        }
//        .onChange(of: percent){
//            result = Double(decimal) + percent
//        }
//        .onAppear {
//            decimal = Int(result)
//            percent = result - Double(decimal)
//        }
//    }
//}
//
//#Preview {
//    DoublePickerView(result: .constant(15.75))
//}

//
//  CheckCircle.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/3/22.
//

import SwiftUI

struct CheckCircle: View {
    var row: Int?
    @Binding var checked: Bool
    @State var showCheckmark: Bool = false
//    @State var checkmarkOpacity: Double = 0.0
//    var checkMark: AnyView = AnyView(
//        Image(systemName: "checkmark")
//            .font(Font.system(size: 18, weight: .regular))
//            .foregroundColor(.black)
//            .transition(.slide)
//            .opacity(checkmarkOpacity)
//    )

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2.0))
                .aspectRatio(contentMode: .fill)
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(.black)
                .background(.pink)
                .onAppear {
                    showCheckmark = checked
                }.clipped().contentShape(Circle())
            if showCheckmark {
                Image(systemName: "checkmark")
                    .font(Font.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
//                    .transition(.scale(scale: 1.0, anchor: .bottomLeading))
            }
        }
        .frame(width: 24, height: 24, alignment: .center)
        .background(.clear)
        .clipShape(Circle())
        .onChange(of: checked) { checked in
            withAnimation(.easeIn(duration: 0.1)) {
                showCheckmark = checked
            }
        }.contentShape(Circle())

    }
}

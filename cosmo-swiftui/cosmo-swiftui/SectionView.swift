//
//  SectionView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/17/22.
//

import SwiftUI

struct SectionView: View {

    @ObservedObject var vM: SectionViewModel

    @State var mouseInView: Bool = false
    @State var mouseX: CGFloat?
    @State private var contentSize: CGSize = .zero


    init(with viewModel: SectionViewModel) {
        self.vM = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer()
                    Text("Hello, world!")
                    Spacer()
                }
                Spacer()
            }
            .background(Color.purple)
            .border(Color.black, width: 2)
            .modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) { self.contentSize = $0 }
            .onContinuousHover(perform: { phase in
                switch phase {
                case .active(let location):
                    if location.x < 3 || location.x > contentSize.width - 3 {
                        NSCursor.resizeLeftRight.push()
                    } else {
                        NSCursor.resizeLeftRight.pop()
                    }
                case .ended:
                    NSCursor.resizeLeftRight.pop()

                }
            })
            

        }
    }
}



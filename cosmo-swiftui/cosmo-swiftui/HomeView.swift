//
//  HomeView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/19/22.
//

import SwiftUI


struct HomeView: View {

    @EnvironmentObject private var appDelegate: AppDelegate

    @ObservedObject var vM: HomeViewModel

    init() {
        vM = HomeViewModel()
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<vM.sections.count, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<vM.sections[row].count, id: \.self) { col in
                        SectionView(with: vM.sections[row][col])
                    }
                }
            }
        }
        .padding(0)
        .onAppear(perform: {
            vM.setUp(with: appDelegate)
        })
    }
}

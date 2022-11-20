//
//  HomeViewModel.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/19/22.
//

import SwiftUI


class HomeViewModel: ObservableObject {

    weak var appDelegate: AppDelegate?

    @Published var sections: [[SectionViewModel]] = []

    func setUp(with appDelegate: AppDelegate) {
        print("setting up")
        sections = [
            [
                SectionViewModel(initialWidth: (appDelegate.screenWidth ?? 0) * 0.2),
                SectionViewModel(),
                SectionViewModel()
            ],
            [
                SectionViewModel(initialHeight: (appDelegate.screenHeight ?? 0) * 0.25)
            ]
        ]
    }


}


//
//  SectionViewModel.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/19/22.
//

import SwiftUI

class SectionViewModel: ObservableObject {
    let uuid = UUID();

    @Published var height: CGFloat?
    @Published var width: CGFloat?

    init(initialHeight: CGFloat? = nil, initialWidth: CGFloat? = nil) {
        self.height = initialHeight
        self.width = initialWidth
    }
}

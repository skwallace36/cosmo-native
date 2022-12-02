//
//  SectionResizeEvent.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/1/22.
//

import SwiftUI

class SectionResizeHandler: ObservableObject {
    @Published var startEdge: ResizeEdge? = nil
    @Published var startSection: Section? = nil

    var resizeType: ResizeType? {
        switch startEdge {
        case .Left, .Right:
            return .Horizontal
        case .Top, .Bottom:
            return .Vertical
        case .none:
            return nil
        }
    }

    func dragInSectionOver() {
        startEdge = nil
        startSection = nil
    }
}

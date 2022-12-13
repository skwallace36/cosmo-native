//
//  Section.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI


extension Section: Equatable, Identifiable, Hashable {
    static func == (lhs: Section, rhs: Section) -> Bool { lhs.sectionId == rhs.sectionId }
    func hash(into hasher: inout Hasher) { hasher.combine(sectionId) }
}

class Section: ObservableObject  {

    var sectionId: Int
    var sectionType: SectionType
    var backgroundColor: Color = .random

    var leftNeighbors: [Section] = []
    var rightNeighbors: [Section] = []
    var topNeighbors: [Section] = []
    var bottomNeighbors: [Section] = []

    var topNeighborsSameWidthAndX: [Section] = []
    var bottomNeighborsSameWidthAndX: [Section] = []

    var edgesToBorder: [Edge] = [.top, .bottom, .trailing, .leading]

    @Published var width: CGFloat
    @Published var widthAdjustment: CGFloat = 0.0
    @Published var widthOffset: CGFloat
    @Published var widthOffsetAdjustment: CGFloat = 0.0

    @Published var height: CGFloat
    @Published var heightAdjustment: CGFloat = 0.0
    @Published var heightOffset: CGFloat
    @Published var heightOffsetAdjustment: CGFloat = 0.0

    init(sectionId: Int, sectionType: SectionType, width: Double, height: Double, widthOffset: CGFloat, heightOffset: CGFloat) {
        self.sectionId = sectionId
        self.sectionType = sectionType
        self.width = CGFloat(width)
        self.height = CGFloat(height)
        self.widthOffset = widthOffset
        self.heightOffset = heightOffset
    }

}



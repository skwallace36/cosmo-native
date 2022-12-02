//
//  Section.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI


enum ResizeType {
    case Horizontal
    case Vertical
}

enum ResizeEdge {
    case Left
    case Right
    case Top
    case Bottom
}


extension Section: Equatable, Identifiable, Hashable {
    static func == (lhs: Section, rhs: Section) -> Bool { lhs.sectionId == rhs.sectionId }
    func hash(into hasher: inout Hasher) { hasher.combine(sectionId) }
}

class Section: ObservableObject  {

    static func fromDecodableSection(_ decodableSection: DecodableSection) -> Section {
        return Section(
            sectionId: decodableSection.sectionId,
            width: decodableSection.size.width,
            height: decodableSection.size.height,
            widthOffset: decodableSection.offset.width,
            heightOffset: decodableSection.offset.height
        )
    }

    var sectionId: Int
    var backgroundColor: Color = .random

    var leftNeighbors: [Section] = []
    var rightNeighbors: [Section] = []
    var topNeighbors: [Section] = []
    var bottomNeighbors: [Section] = []

    var topNeighborsSameWidthAndX: [Section] = []
    var bottomNeighborsSameWidthAndX: [Section] = []

    @Published var width: CGFloat
    @Published var widthAdjustment: CGFloat = 0.0
    @Published var widthOffset: CGFloat
    @Published var widthOffsetAdjustment: CGFloat = 0.0

    @Published var height: CGFloat
    @Published var heightAdjustment: CGFloat = 0.0
    @Published var heightOffset: CGFloat
    @Published var heightOffsetAdjustment: CGFloat = 0.0

    init(sectionId: Int, width: Double, height: Double, widthOffset: CGFloat, heightOffset: CGFloat) {
        self.width = CGFloat(width)
        self.height = CGFloat(height)
        self.widthOffset = widthOffset
        self.heightOffset = heightOffset
        self.sectionId = sectionId
    }
}

struct SectionView: View {

    @StateObject var section: Section

    var resizeHandler: SectionResizeHandler

    @Binding var sectionDrag: DragGesture.Value?
    @Binding var sectionHovering: Section?
    @Binding var sectionHover: HoverPhase?


    var body: some View {
        let myGesture = DragGesture(minimumDistance: 3, coordinateSpace: .named("section")).onChanged({
            resizeHandler.startSection = section
            sectionDrag = $0
        }).onEnded({ _ in
            resizeHandler.dragInSectionOver()
            sectionDrag = nil
        })
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Spacer()
                Text("\(section.sectionId)").fontWeight(.bold).font(.system(size: 20))
                Spacer()
            }
            Spacer()
        }
        .coordinateSpace(name: "section")
        .background(section.backgroundColor)
        .gesture(myGesture)
        .onContinuousHover { phase in
            sectionHovering = section
            sectionHover = phase
        }
    }
}

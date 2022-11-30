//
//  Section.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI


class Section: ObservableObject, Equatable, Identifiable, Hashable  {

    static func fromDecodableSection(_ decodableSection: DecodableSection) -> Section {
        return Section(decodableSection.size.width, decodableSection.size.height, title: decodableSection.id, widthZStackOffset: decodableSection.offset.width, heightZStackOffset: decodableSection.offset.height)
    }

    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }

    var leftNeighbors: [Section] = []
    var rightNeighbors: [Section] = []
    var topNeighbors: [Section] = []
    var bottomNeighbors: [Section] = []
    var rightNeighborsLeftNeighbors: [Section] = []
    var leftNeighborsRightNeighbors: [Section] = []
    var topNeighborsBottomNeighbors: [Section] = []
    var bottomNeighborsTopNeighbors: [Section] = []
    var topNeighborsSameWidthAndX: [Section] = []
    var bottomNeighborsSameWidthAndX: [Section] = []


    @Published var widthMutiplier: CGFloat
    @Published var widthMultiplierAdjustment: CGFloat = 0.0
    @Published var heightMultiplier: CGFloat
    @Published var heightMultiplierAdjustment: CGFloat = 0.0

    @Published var widthZStackOffset: CGFloat
    @Published var widthZStackOffsetAdjustment: CGFloat = 0.0
    @Published var heightZStackOffset: CGFloat
    @Published var heightZStackOffsetAdjustment: CGFloat = 0.0


    var uuid = UUID()
    var title: Int
    var backgroundColor: Color = .random
    init(_ widthMultiplier: Double, _ heightMultiplier: Double, title: Int, widthZStackOffset: CGFloat, heightZStackOffset: CGFloat) {
        self.widthMutiplier = CGFloat(widthMultiplier)
        self.heightMultiplier = CGFloat(heightMultiplier)
        self.widthZStackOffset = widthZStackOffset
        self.heightZStackOffset = heightZStackOffset
        self.title = title
    }
}

struct SectionView: View {

    @StateObject var section: Section

    @Binding var sectionDragging: Section?
    @Binding var sectionDrag: DragGesture.Value?
    @Binding var sectionHovering: Section?
    @Binding var sectionHover: HoverPhase?


    var body: some View {
        let myGesture = DragGesture(minimumDistance: 3, coordinateSpace: .named("section")).onChanged({
            sectionDragging = section
            sectionDrag = $0
        }).onEnded({ _ in
            sectionDragging = nil
            sectionDrag = nil
        })
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Spacer()
                Text("\(section.title)").fontWeight(.bold).font(.system(size: 88))
                Text("\(section.heightMultiplier)")
                Text("\(section.heightZStackOffset)")
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

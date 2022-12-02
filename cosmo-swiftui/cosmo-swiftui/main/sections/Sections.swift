//
//  Sections.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI
        

class MouseHover: ObservableObject, Equatable {
    static func == (lhs: MouseHover, rhs: MouseHover) -> Bool {
        return (lhs.location == rhs.location && lhs.section?.sectionId == rhs.section?.sectionId)
    }

    @Published var section: Section?
    @Published var location: CGPoint?

    func update(with section: Section?, and location: CGPoint?) {
        self.section = section
        self.location = location
    }
}

class Sections: ObservableObject {
    @Published var sections: [Section] = []
    var initialLayout: DecodableSections? = nil

    init(initialLayout: DecodableSections?) {

        // create decodable section objects from initial layout json
        guard let decodableSections = initialLayout?.sections else { return }

        // set sections
        sections.append(contentsOf: decodableSections.map { Section.fromDecodableSection($0) })

        // section section neighbors
        decodableSections.enumerated().forEach { index, decodableSection in
            sections[index].leftNeighbors = sections.filter {
                decodableSection.neighbors.left.firstIndex(of: $0.sectionId) != nil
            }
            sections[index].rightNeighbors = sections.filter {
                decodableSection.neighbors.right.firstIndex(of: $0.sectionId) != nil
            }
            sections[index].topNeighbors = sections.filter {
                decodableSection.neighbors.top.firstIndex(of: $0.sectionId) != nil
            }
            sections[index].bottomNeighbors = sections.filter {
                decodableSection.neighbors.bottom.firstIndex(of: $0.sectionId) != nil
            }

            sections[index].topNeighborsSameWidthAndX = sections.filter {
                decodableSection.neighbors.verticalSameWidthAndX?.up?.firstIndex(of: $0.sectionId) != nil
            }

            sections[index].bottomNeighborsSameWidthAndX = sections.filter {
                decodableSection.neighbors.verticalSameWidthAndX?.down?.firstIndex(of: $0.sectionId) != nil
            }
        }
    }

    func topNeighborsSameWidthAndXRecursive(for section: Section, with topNeighbors: [Section] ) -> [Section] {
        let topNeighborsWithSameWithAndX = topNeighbors.filter {
            $0.width == section.width && $0.widthOffset == section.widthOffset
        }
        return topNeighborsWithSameWithAndX + topNeighborsWithSameWithAndX.flatMap { topNeighborsSameWidthAndXRecursive(for: $0, with: $0.topNeighbors) }
    }

    func bottomNeighborsSameWidthAndXRecursive(for section: Section, with bottomNeighbors: [Section] ) -> [Section] {
        let bottomNeighborsWithSameWithAndX = bottomNeighbors.filter {
            $0.width == section.width && $0.widthOffset == section.widthOffset
        }
        return bottomNeighborsWithSameWithAndX + bottomNeighborsWithSameWithAndX.flatMap { bottomNeighborsSameWidthAndXRecursive(for: $0, with: $0.bottomNeighbors) }
    }
}




struct SectionsView: View {

    @StateObject var sections: Sections
    @StateObject var resizeHandler = SectionResizeHandler()

    @Binding var homeSize: CGSize

    @State var mouseDownWindowLocation: CGPoint?
    @State var sectionDragging: Section?
    @State var sectionDrag: DragGesture.Value?
    @State var globalSectionDrag: DragGesture.Value? = nil
    @State var sectionHovering: Section?
    @State var sectionHover: HoverPhase?
    @State var beganDragEdge: ResizeEdge?
    @State var currentlyResizingSection = false

    let hoverResizeThreshold: CGFloat = 5.0
    @Environment(\.scenePhase)var scenePhase

    var body: some View {

        let gloalDragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged({
            globalSectionDrag = $0
        }).onEnded({ _ in
            globalSectionDrag = nil
        })

        ZStack(alignment: .topLeading) {
            ForEach(sections.sections, id: \.sectionId) { section in
                SectionView(section: section,
                            resizeHandler: resizeHandler,
                            sectionDrag: $sectionDrag,
                            sectionHovering: $sectionHovering,
                            sectionHover: $sectionHover)
                    .frame(
                        width: (section.width * homeSize.width) + section.widthAdjustment,
                        height: (section.height * homeSize.height) + section.heightAdjustment
                    )
                    .offset(
                        CGSize(
                            width: (section.widthOffset * homeSize.width) + section.widthOffsetAdjustment,
                            height: (section.heightOffset * homeSize.height) + section.heightOffsetAdjustment
                        )
                    )
                    .simultaneousGesture(gloalDragGesture)

            }
        }
        .onChange(of: sectionDrag, perform: { [sectionDrag] newValue in
            if sectionDrag != nil && newValue == nil {
                DispatchQueue.main.async {
                    handleEndedSectionDrag()
                }
            } else if sectionDrag != nil && newValue != nil {
                DispatchQueue.main.async {
                    handleActiveSectionDrag(newValue: newValue)
                }
            }
        })
        .onChange(of: sectionHover, perform: { phase in
            guard sectionDrag == nil else { return }
            switch phase {
            case .active(let location):
                handleActiveHover(at: location)
            case .ended, .none:
                break
            }

        })
    }

    func handleActiveSectionDrag(newValue: DragGesture.Value?) {
        switch resizeHandler.startEdge {
        case .Left:
            handleDragFromLeftEdge(newValue)
        case .Right:
            handleDragFromRightEdge(newValue)
        case .Top:
            handleDragFromTopEdge(newValue)
        case .Bottom:
            handleDragFromBottomEdge(newValue)
        case .none:
            break
        }
    }

    func handleEndedSectionDrag() {
        // which type?
        sections.sections.forEach {
            $0.width = $0.width + ($0.widthAdjustment / homeSize.width)
            $0.widthOffset = $0.widthOffset + ($0.widthOffsetAdjustment / homeSize.width)
            $0.widthAdjustment = 0.0
            $0.widthOffsetAdjustment = 0.0
            $0.height = $0.height + ($0.heightAdjustment / homeSize.height)
            $0.heightOffset = $0.heightOffset + ($0.heightOffsetAdjustment / homeSize.height)
            $0.heightAdjustment = 0.0
            $0.heightOffsetAdjustment = 0.0
        }
    }

    func handleDragFromLeftEdge(_ dragEvent: DragGesture.Value?) {
        let dX = globalSectionDrag?.translation.width ?? 0.0
        if dX > 0 {
            let leftNeighbors = resizeHandler.startSection?.leftNeighbors ?? []
            let rightNeighbors = Array(Set((leftNeighbors).flatMap { $0.rightNeighbors }))
            leftNeighbors.forEach {
                $0.widthAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthAdjustment = -dX
                $0.widthOffsetAdjustment = dX
            }
        } else if dX < 0 {
            let leftNeighbors = resizeHandler.startSection?.leftNeighbors
            let rightNeighbors = Array(Set((leftNeighbors ?? []).flatMap { $0.rightNeighbors }))
            leftNeighbors?.forEach {
                $0.widthAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthAdjustment = -dX
                $0.widthOffsetAdjustment = dX
            }
        }
    }

    func handleDragFromRightEdge(_ dragEvent: DragGesture.Value?) {
        let dX = globalSectionDrag?.translation.width ?? 0.0
        if dX > 0 {
            let rightNeighbors = resizeHandler.startSection?.rightNeighbors ?? []
            let leftNeighbors = Array(Set(rightNeighbors.flatMap { $0.leftNeighbors }))
            leftNeighbors.forEach {
                $0.widthAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthAdjustment = -dX
                $0.widthOffsetAdjustment = dX
            }
        } else if dX < 0 {
            let rightNeighbors = resizeHandler.startSection?.rightNeighbors ?? []
            let leftNeighbors = Array(Set(rightNeighbors.flatMap { $0.leftNeighbors }))
            leftNeighbors.forEach {
                $0.widthAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthAdjustment = -dX
                $0.widthOffsetAdjustment = dX
            }
        }
    }

    func handleDragFromTopEdge(_ dragEvent: DragGesture.Value?) {
        let dY = globalSectionDrag?.translation.height ?? 0.0
        if dY < 0 {
            let topNeighbors = resizeHandler.startSection?.topNeighbors ?? []
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            let bottomNeighbors = Array(Set(topNeighbors.flatMap { $0.bottomNeighbors }))
            bottomNeighbors.forEach {
                $0.heightAdjustment = -dY
                $0.heightOffsetAdjustment = dY
            }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, section) in
                    let dividedDeltaY = dY / CGFloat(group.count)
                    section.heightOffsetAdjustment = dividedDeltaY * CGFloat(index)
                    section.heightAdjustment = dividedDeltaY
                }
            }
        } else if dY > 0 {
            let topNeighbors = resizeHandler.startSection?.topNeighbors ?? []
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            let bottomNeighbors = Array(Set(topNeighbors.flatMap { $0.bottomNeighbors }))
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, section) in
                    section.heightOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    section.heightAdjustment = dY / CGFloat(group.count)
                }
            }
            bottomNeighbors.forEach {
                $0.heightAdjustment = -dY
                $0.heightOffsetAdjustment = dY
            }
        }
    }

    func handleDragFromBottomEdge(_ dragEvent: DragGesture.Value?) {
        let dY = globalSectionDrag?.translation.height ?? 0
        if dY < 0 {
            let bottomNeighbors = resizeHandler.startSection?.bottomNeighbors ?? []
            bottomNeighbors.forEach {
                $0.heightAdjustment = -dY
                $0.heightOffsetAdjustment = dY
            }
            let topNeighbors = Array(Set(bottomNeighbors.flatMap { $0.topNeighbors }))
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, section) in
                    section.heightOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    section.heightAdjustment = (dY / CGFloat(group.count))
                }
            }
        } else if dY > 0 {
            let bottomNeighbors = resizeHandler.startSection?.bottomNeighbors ?? []
            bottomNeighbors.forEach {
                $0.heightAdjustment = -dY
                $0.heightOffsetAdjustment = dY
            }
            let topNeighbors = Array(Set(bottomNeighbors.flatMap { $0.topNeighbors }))
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, section) in
                    section.heightOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    section.heightAdjustment = (dY / CGFloat(group.count))
                }
            }
        }
    }

    func handleActiveHover(at location: CGPoint) {
        setCursor(at: location)
    }

    func setCursor(at location: CGPoint) {
        guard sectionDragging == nil else { return }
        guard let sectionHovering = sectionHovering else { return }
        
        if onLeftEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            resizeHandler.startEdge = .Left
            return
        }

        if onRightEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            resizeHandler.startEdge = .Right
            return
        }

        if onTopEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            resizeHandler.startEdge = .Top
            return
        }

        if onBottomEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            resizeHandler.startEdge = .Bottom
            return
        }

        NSCursor.arrow.popThenPush()
    }

    func onLeftEdge(at location: CGPoint, for section: Section) -> Bool { location.x < hoverResizeThreshold }

    func onRightEdge(at location: CGPoint, for section: Section) -> Bool {
        let sectionWidth = section.width * homeSize.width
        return location.x > sectionWidth - hoverResizeThreshold
    }

    func onTopEdge(at location: CGPoint, for section: Section) -> Bool { location.y < hoverResizeThreshold }

    func onBottomEdge(at location: CGPoint, for section: Section) -> Bool {
        let sectionHeight = section.height * homeSize.height
        return location.y > sectionHeight - hoverResizeThreshold
    }
}

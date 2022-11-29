//
//  Sections.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI
        

class MouseHover: ObservableObject, Equatable {
    static func == (lhs: MouseHover, rhs: MouseHover) -> Bool {
        return (lhs.location == rhs.location && lhs.section?.uuid == rhs.section?.uuid)
    }

    @Published var section: Section?
    @Published var location: CGPoint?

    func update(with section: Section?, and location: CGPoint?) {
        self.section = section
        self.location = location
    }
}

enum ResizeEdge {
    case Left
    case Right
    case Top
    case Bottom
}

class Sections: ObservableObject {
    @Published var sections: [Section] = []

    init() {
        let sectionOne = Section(0.25, 0.35, title: "1", widthZStackOffset: 0.0, heightZStackOffset: 0.0)
        let sectionTwo = Section(0.25, 0.35, title: "2", widthZStackOffset: 0.0, heightZStackOffset: 0.35)
        let sectionThree = Section(0.375, 0.7, title: "3", widthZStackOffset: 0.25, heightZStackOffset: 0.0)
        let sectionFour = Section(0.375, 0.7, title: "4", widthZStackOffset: 0.625, heightZStackOffset: 0.0)
        let sectionFive = Section(1, 0.3, title: "5", widthZStackOffset: 0.0, heightZStackOffset: 0.7)

        sectionOne.bottomNeighbors.append(sectionTwo)
        sectionOne.rightNeighbors.append(sectionThree)

        sectionTwo.rightNeighbors.append(sectionThree)
        sectionTwo.topNeighbors.append(sectionOne)
        sectionTwo.bottomNeighbors.append(sectionFive)

        sectionThree.leftNeighbors.append(contentsOf: [sectionOne, sectionTwo])
        sectionThree.rightNeighbors.append(sectionFour)
        sectionThree.bottomNeighbors.append(sectionFive)

        sectionFour.leftNeighbors.append(sectionThree)
        sectionFour.bottomNeighbors.append(sectionFive)

        sectionFive.topNeighbors.append(contentsOf: [sectionTwo, sectionThree, sectionFour])


        sections.append(contentsOf: [sectionOne, sectionTwo, sectionThree, sectionFour, sectionFive])
        sections.forEach {
            $0.rightNeighborsLeftNeighbors = Array(Set($0.rightNeighbors.flatMap { $0.leftNeighbors }))
            $0.leftNeighborsRightNeighbors = Array(Set($0.leftNeighbors.flatMap { $0.rightNeighbors }))
            $0.topNeighborsBottomNeighbors = Array(Set($0.topNeighbors.flatMap { $0.bottomNeighbors }))
            $0.bottomNeighborsTopNeighbors = Array(Set($0.bottomNeighbors.flatMap { $0.topNeighbors }))
            $0.topNeighborsSameWidthAndX = topNeighborsSameWidthAndXRecursive(for: $0, with: $0.topNeighbors)
            $0.bottomNeighborsSameWidthAndX = bottomNeighborsSameWidthAndXRecursive(for: $0, with: $0.bottomNeighbors)
        }
    }

    func topNeighborsSameWidthAndXRecursive(for section: Section, with topNeighbors: [Section] ) -> [Section] {
        let topNeighborsWithSameWithAndX = topNeighbors.filter {
            $0.widthMutiplier == section.widthMutiplier && $0.widthZStackOffset == section.widthZStackOffset
        }
        return topNeighborsWithSameWithAndX + topNeighborsWithSameWithAndX.flatMap { topNeighborsSameWidthAndXRecursive(for: $0, with: $0.topNeighbors) }
    }

    func bottomNeighborsSameWidthAndXRecursive(for section: Section, with bottomNeighbors: [Section] ) -> [Section] {
        let bottomNeighborsWithSameWithAndX = bottomNeighbors.filter {
            $0.widthMutiplier == section.widthMutiplier && $0.widthZStackOffset == section.widthZStackOffset
        }
        return bottomNeighborsWithSameWithAndX + bottomNeighborsWithSameWithAndX.flatMap { bottomNeighborsSameWidthAndXRecursive(for: $0, with: $0.bottomNeighbors) }
    }
}

struct SectionsView: View {

    @StateObject var sections = Sections()

    @Binding var homeSize: CGSize

    @State var mouseDownWindowLocation: CGPoint?
    @State var sectionDragging: Section?
    @State var sectionDrag: DragGesture.Value?
    @State var globalSectionDrag: DragGesture.Value? = nil
    @State var sectionHovering: Section?
    @State var sectionHover: HoverPhase?
    @State var canResizeASection: Bool = false
    @State var beganDragEdge: ResizeEdge?
    @State var currentlyResizingSection = false

    let hoverResizeThreshold: CGFloat = 5.0
    @Environment(\.scenePhase)var scenePhase

    var body: some View {

        let myGesture = DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged({
            globalSectionDrag = $0
        }).onEnded({ _ in
            globalSectionDrag = nil
        })

        ZStack(alignment: .topLeading) {
            ForEach(sections.sections, id: \.title) { section in
                SectionView(section: section,
                            sectionDragging: $sectionDragging,
                            sectionDrag: $sectionDrag,
                            sectionHovering: $sectionHovering,
                            sectionHover: $sectionHover)
                    .frame(
                        width: (section.widthMutiplier * homeSize.width) + section.widthMultiplierAdjustment,
                        height: (section.heightMultiplier * homeSize.height) + section.heightMultiplierAdjustment
                    )
                    .offset(
                        CGSize(
                            width: (section.widthZStackOffset * homeSize.width) + section.widthZStackOffsetAdjustment,
                            height: (section.heightZStackOffset * homeSize.height) + section.heightZStackOffsetAdjustment
                        )
                    )
                    .simultaneousGesture(myGesture)

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
        guard sectionDragging != nil else { return }
        switch beganDragEdge {
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
            $0.widthMutiplier = $0.widthMutiplier + ($0.widthMultiplierAdjustment / homeSize.width)
            $0.widthZStackOffset = $0.widthZStackOffset + ($0.widthZStackOffsetAdjustment / homeSize.width)
            $0.widthMultiplierAdjustment = 0.0
            $0.widthZStackOffsetAdjustment = 0.0
            print("setting \($0.title) height: multiplier to: \($0.heightMultiplier + ($0.heightMultiplierAdjustment / homeSize.height))")
            $0.heightMultiplier = $0.heightMultiplier + ($0.heightMultiplierAdjustment / homeSize.height)
            $0.heightZStackOffset = $0.heightZStackOffset + ($0.heightZStackOffsetAdjustment / homeSize.height)
            $0.heightMultiplierAdjustment = 0.0
            $0.heightZStackOffsetAdjustment = 0.0
        }
    }

    func handleDragFromLeftEdge(_ dragEvent: DragGesture.Value?) {
        guard let sectionDragging = sectionDragging, let globalSectionDrag = globalSectionDrag else { return }
        let dX = globalSectionDrag.translation.width
        if dX > 0 {
            let leftNeighbors = sectionDragging.leftNeighbors
            let rightNeighbors = Array(Set(leftNeighbors.flatMap { $0.rightNeighbors }))
            leftNeighbors.forEach {
                $0.widthMultiplierAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthMultiplierAdjustment = -dX
                $0.widthZStackOffsetAdjustment = dX
            }
        } else if dX < 0 {
            let leftNeighbors = sectionDragging.leftNeighbors
            let rightNeighbors = Array(Set(leftNeighbors.flatMap { $0.rightNeighbors }))
            leftNeighbors.forEach {
                $0.widthMultiplierAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthMultiplierAdjustment = -dX
                $0.widthZStackOffsetAdjustment = dX
            }
        }
    }

    func handleDragFromRightEdge(_ dragEvent: DragGesture.Value?) {
        guard let sectionDragging = sectionDragging, let globalSectionDrag = globalSectionDrag else { return }
        let dX = globalSectionDrag.translation.width
        if dX > 0 {
            let rightNeighbors = sectionDragging.rightNeighbors
            let leftNeighbors = Array(Set(rightNeighbors.flatMap { $0.leftNeighbors }))
            leftNeighbors.forEach {
                $0.widthMultiplierAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthMultiplierAdjustment = -dX
                $0.widthZStackOffsetAdjustment = dX
            }
        } else if dX < 0 {
            let rightNeighbors = sectionDragging.rightNeighbors
            let leftNeighbors = Array(Set(rightNeighbors.flatMap { $0.leftNeighbors }))
            leftNeighbors.forEach {
                $0.widthMultiplierAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthMultiplierAdjustment = -dX
                $0.widthZStackOffsetAdjustment = dX
            }
        }
    }

    func handleDragFromTopEdge(_ dragEvent: DragGesture.Value?) {
        guard let sectionDragging = sectionDragging, let globalSectionDrag = globalSectionDrag else { return }
        let dY = globalSectionDrag.translation.height
        if dY < 0 {
            let topNeighbors = sectionDragging.topNeighbors
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            let bottomNeighbors = Array(Set(topNeighbors.flatMap { $0.bottomNeighbors }))
            bottomNeighbors.forEach {
                $0.heightMultiplierAdjustment = -dY
                $0.heightZStackOffsetAdjustment = dY
            }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, section) in
                    let dividedDeltaY = dY / CGFloat(group.count)
                    section.heightZStackOffsetAdjustment = dividedDeltaY * CGFloat(index)
                    section.heightMultiplierAdjustment = dividedDeltaY
                }
            }
        } else if dY > 0 {
            let topNeighbors = sectionDragging.topNeighbors
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            let bottomNeighbors = Array(Set(topNeighbors.flatMap { $0.bottomNeighbors }))
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, section) in
                    section.heightZStackOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    section.heightMultiplierAdjustment = dY / CGFloat(group.count)
                }
            }
            bottomNeighbors.forEach {
                $0.heightMultiplierAdjustment = -dY
                $0.heightZStackOffsetAdjustment = dY
            }
        }
    }

    func handleDragFromBottomEdge(_ dragEvent: DragGesture.Value?) {
        guard let sectionDragging = sectionDragging, let globalSectionDrag = globalSectionDrag else { return }
        let dY = globalSectionDrag.translation.height
        if dY < 0 {
            let bottomNeighbors = sectionDragging.bottomNeighbors
            bottomNeighbors.forEach {
                $0.heightMultiplierAdjustment = -dY
                $0.heightZStackOffsetAdjustment = dY
            }
            let topNeighbors = Array(Set(bottomNeighbors.flatMap { $0.topNeighbors }))
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, section) in
                    section.heightZStackOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    section.heightMultiplierAdjustment = (dY / CGFloat(group.count))
                }
            }
        } else if dY > 0 {
            let bottomNeighbors = sectionDragging.bottomNeighbors
            bottomNeighbors.forEach {
                $0.heightMultiplierAdjustment = -dY
                $0.heightZStackOffsetAdjustment = dY
            }
            let topNeighbors = Array(Set(bottomNeighbors.flatMap { $0.topNeighbors }))
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, section) in
                    section.heightZStackOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    section.heightMultiplierAdjustment = (dY / CGFloat(group.count))
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
            beganDragEdge = .Left
            return
        }

        if onRightEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            beganDragEdge = .Right
            return
        }

        if onTopEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            beganDragEdge = .Top
            return
        }

        if onBottomEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            beganDragEdge = .Bottom
            return
        }

        NSCursor.arrow.popThenPush()
    }

    func onLeftEdge(at location: CGPoint, for section: Section) -> Bool { location.x < hoverResizeThreshold }

    func onRightEdge(at location: CGPoint, for section: Section) -> Bool {
        let sectionWidth = section.widthMutiplier * homeSize.width
        return location.x > sectionWidth - hoverResizeThreshold
    }

    func onTopEdge(at location: CGPoint, for section: Section) -> Bool { location.y < hoverResizeThreshold }

    func onBottomEdge(at location: CGPoint, for section: Section) -> Bool {
        let sectionHeight = section.heightMultiplier * homeSize.height
        return location.y > sectionHeight - hoverResizeThreshold
    }
}

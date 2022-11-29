//
//  Sections.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI

//class Sections: ObservableObject {
//
//    @Binding var sections: [Section]
//
//    
//
//    func cumulativeLeftWidthMultiplier(section: Section?) -> CGFloat {
//        guard let section = section else { return 0.0 }
//        guard section.leftNeighbors.count != 0 else { return 0.0 }
//        let widest = section.leftNeighbors.max(by: {$0.widthMutiplier > $1.widthMutiplier} )
//        return (widest?.widthMutiplier ?? 0) + cumulativeLeftWidthMultiplier(section: widest)
//    }
//
//    func cumulativeTopHeightMultiplier(section: Section?) -> CGFloat {
//        guard let section = section else { return 0.0 }
//        guard section.topNeighbors.count != 0 else { return 0.0 }
//        let tallest = section.topNeighbors.max(by: {$0.heightMultiplier > $1.heightMultiplier} )
//        return (tallest?.heightMultiplier ?? 0) + cumulativeTopHeightMultiplier(section: tallest)
//    }
////
//    func setZStackOffsets() {
////        for section in sections {
////            section.heightZStackOffset = section.cumulativeTopHeightMultiplier(section: section)
////            section.widthZStackOffset = section.cumulativeLeftWidthMultiplier(section: section)
////        }
//    }
//}

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
        let sectionOne = Section(0.25, 0.35, title: "sectionOne", widthZStackOffset: 0.0, heightZStackOffset: 0.0)
        let sectionFive = Section(0.25, 0.35, title: "sectionFive", widthZStackOffset: 0.0, heightZStackOffset: 0.35)
        let sectionTwo = Section(0.375, 0.7, title: "sectionTwo", widthZStackOffset: 0.25, heightZStackOffset: 0.0)
        let sectionThree = Section(0.375, 0.7, title: "sectionThree", widthZStackOffset: 0.625, heightZStackOffset: 0.0)
        let sectionFour = Section(1, 0.3, title: "sectionFour", widthZStackOffset: 0.0, heightZStackOffset: 0.7)
        [sectionTwo, sectionThree].forEach({ $0.bottomNeighbors.append(sectionFour) })

        sectionFour.topNeighbors.append(contentsOf: [sectionFive, sectionTwo, sectionThree])

        sectionOne.bottomNeighbors.append(sectionFive)
        sectionOne.rightNeighbors.append(sectionTwo)

        sectionFive.rightNeighbors.append(sectionTwo)
        sectionFive.topNeighbors.append(sectionOne)

        sectionTwo.leftNeighbors.append(contentsOf: [sectionOne, sectionFive])
        sectionTwo.rightNeighbors.append(sectionThree)
        sectionTwo.bottomNeighbors.append(sectionFour)

        sectionThree.leftNeighbors.append(sectionTwo)
        sectionThree.bottomNeighbors.append(sectionFour)

        sections.append(contentsOf: [sectionOne, sectionTwo, sectionThree, sectionFour, sectionFive])
        sections.forEach {
            $0.rightNeighborsLeftNeighbors = Array(Set($0.rightNeighbors.flatMap { $0.leftNeighbors }))
            $0.leftNeighborsRightNeighbors = Array(Set($0.leftNeighbors.flatMap { $0.rightNeighbors }))
            $0.topNeighborsBottomNeighbors = Array(Set($0.topNeighbors.flatMap { $0.bottomNeighbors }))
            $0.bottomNeighborsTopNeighbors = Array(Set($0.bottomNeighbors.flatMap { $0.topNeighbors }))
            $0.topNeighborsSameWidthAndX = topNeighborsSameWidthAndXRecursive(for: $0, with: $0.topNeighbors)
        }
    }

    func topNeighborsSameWidthAndXRecursive(for section: Section, with topNeighbors: [Section] ) -> [Section] {
        let topNeighborsWithSameWithAndX = topNeighbors.filter {
            $0.widthMutiplier == section.widthMutiplier &&
                $0.widthZStackOffset == section.widthZStackOffset
        }

        return topNeighborsWithSameWithAndX + topNeighborsWithSameWithAndX.flatMap { topNeighborsSameWidthAndXRecursive(for: $0, with: $0.topNeighbors) }
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
            topNeighbors.forEach {
                $0.heightMultiplierAdjustment = dY
            }
        } else if dY > 0 {
            let topNeighbors = sectionDragging.topNeighbors
            let bottomNeighbors = Array(Set(topNeighbors.flatMap { $0.bottomNeighbors }))
            sectionDragging.topNeighbors.forEach {
                $0.heightMultiplierAdjustment = dY
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
            let topNeighbors = Array(Set(bottomNeighbors.flatMap { $0.topNeighbors }))
            bottomNeighbors.forEach {
                $0.heightMultiplierAdjustment = -dY
                $0.heightZStackOffsetAdjustment = dY
            }
            topNeighbors.forEach {
                $0.heightMultiplierAdjustment = dY
            }

        } else if dY > 0 {
            let bottomNeighbors = sectionDragging.bottomNeighbors
            let topNeighbors = Array(Set(bottomNeighbors.flatMap { $0.topNeighbors }))
            bottomNeighbors.forEach {
                $0.heightMultiplierAdjustment = -dY
                $0.heightZStackOffsetAdjustment = dY
            }
            topNeighbors.forEach {
                $0.heightMultiplierAdjustment = dY
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

    func onLeftEdge(at location: CGPoint, for section: Section) -> Bool {
        return location.x < hoverResizeThreshold
    }

    func onRightEdge(at location: CGPoint, for section: Section) -> Bool {
        let sectionWidth = section.widthMutiplier * homeSize.width
        return location.x > sectionWidth - hoverResizeThreshold
    }

    func onTopEdge(at location: CGPoint, for section: Section) -> Bool {
        return location.y < hoverResizeThreshold
    }

    func onBottomEdge(at location: CGPoint, for section: Section) -> Bool {
//        print(section.heightMultiplier)
        let sectionHeight = section.heightMultiplier * homeSize.height
//        print(sectionHeight)
//        print(location.y)
        return location.y > sectionHeight - hoverResizeThreshold
    }
}

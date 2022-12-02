//
//  SectionResizeEvent.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/1/22.
//

import SwiftUI

class SectionsResizeHandler: ObservableObject {
    @Published var startEdge: ResizeEdge? = nil
    @Published var startSection: Section? = nil
    @Published var localSectionDrag: DragGesture.Value? {
        didSet {
            DispatchQueue.main.async { [localSectionDrag] in
                if oldValue != nil && localSectionDrag == nil {
                    self.globalSectionDragOver()
                } else if oldValue != nil && localSectionDrag != nil {
                    self.handleActiveSectionDrag(newValue: localSectionDrag)
                }
            }
        }
    }
    @Published var globalSectionDrag: DragGesture.Value?
    @Published var sectionHovering: Section?
    @Published var sectionHover: HoverPhase? {
        didSet {
            switch sectionHover {
            case .active(let location):
                handleActiveHover(at: location)
            case .ended, .none:
                break
            }
        }
    }
    @Binding var homeSize: CGSize
    var sections: Sections
    let hoverResizeThreshold: CGFloat = 5.0


    init(homeSize: Binding<CGSize>, sections: Sections) {
        self._homeSize = homeSize
        self.sections = sections
    }

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

    func localSectionDragOver() {
        startEdge = nil
        startSection = nil
    }

    func globalSectionDragOver() {
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

    func handleEndedSectionDrag() {
    }

    func handleActiveSectionDrag(newValue: DragGesture.Value?) {
        switch startEdge {
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

    func handleActiveHover(at location: CGPoint) {
        setCursor(at: location)
    }
    func setCursor(at location: CGPoint) {
        guard startSection == nil else { return }
        guard let sectionHovering = sectionHovering else { return }

        if onLeftEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            startEdge = .Left
            return
        }

        if onRightEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            startEdge = .Right
            return
        }

        if onTopEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            startEdge = .Top
            return
        }

        if onBottomEdge(at: location, for: sectionHovering) {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            startEdge = .Bottom
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

    func handleDragFromLeftEdge(_ dragEvent: DragGesture.Value?) {
        let dX = globalSectionDrag?.translation.width ?? 0.0
        if dX > 0 {
            let leftNeighbors = startSection?.leftNeighbors ?? []
            let rightNeighbors = Array(Set((leftNeighbors).flatMap { $0.rightNeighbors }))
            leftNeighbors.forEach {
                $0.widthAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthAdjustment = -dX
                $0.widthOffsetAdjustment = dX
            }
        } else if dX < 0 {
            let leftNeighbors = startSection?.leftNeighbors
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
            let rightNeighbors = startSection?.rightNeighbors ?? []
            let leftNeighbors = Array(Set(rightNeighbors.flatMap { $0.leftNeighbors }))
            leftNeighbors.forEach {
                $0.widthAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthAdjustment = -dX
                $0.widthOffsetAdjustment = dX
            }
        } else if dX < 0 {
            let rightNeighbors = startSection?.rightNeighbors ?? []
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
            let topNeighbors = startSection?.topNeighbors ?? []
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
            let topNeighbors = startSection?.topNeighbors ?? []
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
            let bottomNeighbors = startSection?.bottomNeighbors ?? []
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
            let bottomNeighbors = startSection?.bottomNeighbors ?? []
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
}

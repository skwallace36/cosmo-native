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
            self.handleLocalSectionDrag(oldValue: oldValue, newValue: localSectionDrag)
        }
    }
    @Published var globalSectionDrag: DragGesture.Value? {
        didSet {
            self.handleGlobalSectionDrag(oldValue: oldValue, newValue: globalSectionDrag)
        }
    }
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

    @Published var activelyResizing = false

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



    func handleGlobalSectionDrag(oldValue: DragGesture.Value?, newValue: DragGesture.Value?) {
        if newValue == nil && oldValue != nil {
            globalSectionDragOver(at: oldValue?.location)
            return
        }
    }

    func handleLocalSectionDrag(oldValue: DragGesture.Value?, newValue: DragGesture.Value?) {
        if newValue == nil && oldValue != nil {
            globalSectionDragOver(at: oldValue?.location)
            return
        }
        guard let newValue = newValue else { return }
        localSectionDragActive(newValue: newValue)
    }

    func globalSectionDragOver(at location: CGPoint?) {
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
        activelyResizing = false
        guard let location = location else { return }
        setCursor(at: location)
    }




    func localSectionDragActive(newValue: DragGesture.Value) {
        switch startEdge {
        case .Left:
            activelyResizing = true
            handleDragFromLeftEdge(newValue)
        case .Right:
            activelyResizing = true
            handleDragFromRightEdge(newValue)
        case .Top:
            activelyResizing = true
            handleDragFromTopEdge(newValue)
        case .Bottom:
            activelyResizing = true
            handleDragFromBottomEdge(newValue)
        case .none:
            break
        }
    }

    func handleActiveHover(at location: CGPoint) {
        setCursor(at: location)
    }
    func setCursor(at location: CGPoint) {
        guard activelyResizing != true else { return }
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

        if NSCursor.current != NSCursor.arrow {
            NSCursor.pop()
        }
        startEdge = .none
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

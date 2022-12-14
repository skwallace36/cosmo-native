//
//  BlockResizeEvent.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/1/22.
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

class BlocksResizeHandler: ObservableObject {
    @ObservedObject var homeSize: HomeSize
    @ObservedObject var blocksProvider: BlocksProvider

    init(_ homeSize: HomeSize, _ blocksProvider: BlocksProvider) {
        self.homeSize = homeSize
        self.blocksProvider = blocksProvider
        print("made blocks resize handler")
    }

    @Published var startBlock: Block? = nil
    @Published var localBlockDrag: DragGesture.Value? {
        didSet {
            handleLocalBlockDrag(oldValue: oldValue, newValue: localBlockDrag)
        }
    }
    @Published var globalBlockDrag: DragGesture.Value? {
        didSet {
            handleGlobalBlockDrag(oldValue: oldValue, newValue: globalBlockDrag)
        }
    }
    var lastEdgeHovered: ResizeEdge? = nil
    @Published var blockHovering: Block?
    @Published var blockHover: HoverPhase? {
        didSet {
            switch blockHover {
            case .active(let location):
                handleActiveHover(at: location)
            case .ended, .none:
                break
            }
        }
    }

    let hoverResizeThreshold: CGFloat = 5.0

    @Published var activelyResizing = false


    var resizeType: ResizeType? {
        switch lastEdgeHovered {
        case .Left, .Right:
            return .Horizontal
        case .Top, .Bottom:
            return .Vertical
        case .none:
            return nil
        }
    }



    func handleGlobalBlockDrag(oldValue: DragGesture.Value?, newValue: DragGesture.Value?) {
        if newValue == nil && oldValue != nil {
            globalBlockDragOver(at: oldValue?.location)
            return
        }
    }

    func handleLocalBlockDrag(oldValue: DragGesture.Value?, newValue: DragGesture.Value?) {
        if newValue == nil && oldValue != nil {
            globalBlockDragOver(at: oldValue?.location)
            return
        }
        guard let newValue = newValue else { return }
        localBlockDragActive(newValue: newValue)
    }

    func globalBlockDragOver(at location: CGPoint?) {
//        guard let homeSize = homeSize else { return }
        blocksProvider.blocks.forEach {
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


    func localBlockDragActive(newValue: DragGesture.Value) {
        switch lastEdgeHovered {
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
        guard let blockHovering = blockHovering else { return }

        if onLeftEdge(at: location, for: blockHovering) {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            lastEdgeHovered = .Left
            return
        }

        if onRightEdge(at: location, for: blockHovering) {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            lastEdgeHovered = .Right
            return
        }

        if onTopEdge(at: location, for: blockHovering) {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            lastEdgeHovered = .Top
            return
        }

        if onBottomEdge(at: location, for: blockHovering) {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            lastEdgeHovered = .Bottom
            return
        }

        if NSCursor.current != NSCursor.arrow {
            NSCursor.pop()
        }
        lastEdgeHovered = .none
    }

    func onLeftEdge(at location: CGPoint, for block: Block) -> Bool { location.x < hoverResizeThreshold }

    func onRightEdge(at location: CGPoint, for block: Block) -> Bool {
//        guard let homeSize = homeSize else { return false }
        let blockWidth = block.width * homeSize.width
        return location.x > blockWidth - hoverResizeThreshold
    }

    func onTopEdge(at location: CGPoint, for block: Block) -> Bool { location.y < hoverResizeThreshold }

    func onBottomEdge(at location: CGPoint, for block: Block) -> Bool {
//        guard let homeSize = homeSize else { return false }
        let blockHeight = block.height * homeSize.height
        return location.y > blockHeight - hoverResizeThreshold
    }

    func handleDragFromLeftEdge(_ dragEvent: DragGesture.Value?) {
        let dX = globalBlockDrag?.translation.width ?? 0.0
        if dX > 0 {
            let leftNeighbors = startBlock?.leftNeighbors ?? []
            let rightNeighbors = Array(Set((leftNeighbors).flatMap { $0.rightNeighbors }))
            leftNeighbors.forEach {
                $0.widthAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthAdjustment = -dX
                $0.widthOffsetAdjustment = dX
            }
        } else if dX < 0 {
            let leftNeighbors = startBlock?.leftNeighbors
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
        let dX = globalBlockDrag?.translation.width ?? 0.0
        if dX > 0 {
            let rightNeighbors = startBlock?.rightNeighbors ?? []
            let leftNeighbors = Array(Set(rightNeighbors.flatMap { $0.leftNeighbors }))
            leftNeighbors.forEach {
                $0.widthAdjustment = dX
            }
            rightNeighbors.forEach {
                $0.widthAdjustment = -dX
                $0.widthOffsetAdjustment = dX
            }
        } else if dX < 0 {
            let rightNeighbors = startBlock?.rightNeighbors ?? []
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
        let dY = globalBlockDrag?.translation.height ?? 0.0
        if dY < 0 {
            let topNeighbors = startBlock?.topNeighbors ?? []
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            let bottomNeighbors = Array(Set(topNeighbors.flatMap { $0.bottomNeighbors }))
            bottomNeighbors.forEach {
                $0.heightAdjustment = -dY
                $0.heightOffsetAdjustment = dY
            }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, block) in
                    let dividedDeltaY = dY / CGFloat(group.count)
                    block.heightOffsetAdjustment = dividedDeltaY * CGFloat(index)
                    block.heightAdjustment = dividedDeltaY
                }
            }
        } else if dY > 0 {
            let topNeighbors = startBlock?.topNeighbors ?? []
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            let bottomNeighbors = Array(Set(topNeighbors.flatMap { $0.bottomNeighbors }))
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, block) in
                    block.heightOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    block.heightAdjustment = dY / CGFloat(group.count)
                }
            }
            bottomNeighbors.forEach {
                $0.heightAdjustment = -dY
                $0.heightOffsetAdjustment = dY
            }
        }
    }

    func handleDragFromBottomEdge(_ dragEvent: DragGesture.Value?) {
        let dY = globalBlockDrag?.translation.height ?? 0
        if dY < 0 {
            let bottomNeighbors = startBlock?.bottomNeighbors ?? []
            bottomNeighbors.forEach {
                $0.heightAdjustment = -dY
                $0.heightOffsetAdjustment = dY
            }
            let topNeighbors = Array(Set(bottomNeighbors.flatMap { $0.topNeighbors }))
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, block) in
                    block.heightOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    block.heightAdjustment = (dY / CGFloat(group.count))
                }
            }
        } else if dY > 0 {
            let bottomNeighbors = startBlock?.bottomNeighbors ?? []
            bottomNeighbors.forEach {
                $0.heightAdjustment = -dY
                $0.heightOffsetAdjustment = dY
            }
            let topNeighbors = Array(Set(bottomNeighbors.flatMap { $0.topNeighbors }))
            let topNeighborGroups = topNeighbors.compactMap { $0.topNeighborsSameWidthAndX + [$0] }
            topNeighborGroups.forEach { group in
                group.enumerated().forEach { (index, block) in
                    block.heightOffsetAdjustment = (dY / CGFloat(group.count)) * CGFloat(index)
                    block.heightAdjustment = (dY / CGFloat(group.count))
                }
            }
        }
    }
}

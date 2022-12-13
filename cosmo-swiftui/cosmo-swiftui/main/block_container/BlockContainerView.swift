//
//  BlockContainer.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/5/22.
//

import SwiftUI

struct BlockContainerView: View {
    @ObservedObject var container: BlockContainer
    @ObservedObject var resizeHandler: BlocksResizeHandler
    @ObservedObject var splitHandler: BlocksSplitHandler

    init(container: BlockContainer) {
        self.container = container
        self.resizeHandler = container.resizeHandler
        self.splitHandler = container.splitHandler
    }
    var block: Block { container.block }
    
    var body: some View {
        let localDrag = DragGesture(minimumDistance: 3, coordinateSpace: .named("block")).onChanged({
            resizeHandler.startBlock = block
            resizeHandler.localBlockDrag = $0
        }).onEnded({ _ in
            resizeHandler.localBlockDrag = nil
        })
        BlockView(block: block).background(.pink)
        .overlay {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(localDrag)
                .coordinateSpace(name: "block")
                .contextMenu {
                    ForEach(container.blockActions, id: \.self) { action in
                        Button(action.label) {
                            clickedContextMenuAction(action)
                        }
                    }

                }
        }
        .onContinuousHover { phase in
            resizeHandler.blockHovering = block
            resizeHandler.blockHover = phase
        }
    }

    func clickedContextMenuAction(_ action: BlockAction) {
        switch action {
        case .Split(let direction):
            splitHandler.splitBlock(direction, block: block)
        }
    }
}

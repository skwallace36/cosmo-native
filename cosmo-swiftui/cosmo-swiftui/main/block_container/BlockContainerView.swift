//
//  BlockContainer.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/5/22.
//

import SwiftUI

struct BlockContainerView: View {
    @ObservedObject var container: BlockContainer
    @ObservedObject var blocksResizeHandler: BlocksResizeHandler
    @ObservedObject var blocksSplitHandler: BlocksSplitHandler

    init(container: BlockContainer, blocksResizeHandler: BlocksResizeHandler, blocksSplitHandler: BlocksSplitHandler) {
        self.container = container
        self.blocksResizeHandler = blocksResizeHandler
        self.blocksSplitHandler = blocksSplitHandler
    }
    var block: Block { container.block }
    
    var body: some View {
        let localDrag = DragGesture(minimumDistance: 3, coordinateSpace: .named("block")).onChanged({
            blocksResizeHandler.startBlock = block
            blocksResizeHandler.localBlockDrag = $0
        }).onEnded({ _ in
            blocksResizeHandler.localBlockDrag = nil
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
            blocksResizeHandler.blockHovering = block
            blocksResizeHandler.blockHover = phase
        }
    }

    func clickedContextMenuAction(_ action: BlockAction) {
        switch action {
        case .Split(let direction):
            blocksSplitHandler.splitBlock(direction, block: block)
        }
    }
}

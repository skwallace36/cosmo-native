//
//  BlockContainer.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/5/22.
//

import SwiftUI

struct BlockContainerView: View {
    @StateObject var container: BlockContainer
    var block: Block { container.block }
    var resizeHandler: BlocksResizeHandler { container.resizeHandler }
    
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
                    ForEach(container.contextMenuActions, id: \.self) { action in
                        Button(action.label) {
                            clickedContextMenuAction(action)
                        }
                    }

                }
        }
        .onContinuousHover { phase in
            resizeHandler.blockHovering = block
            resizeHandler.blockHover = phase
        }.onAppear {
            print("on appear block view")
        }
    }

    func clickedContextMenuAction(_ action: BlockContainerContextMenuAction) {
        switch action {
        case .Split(let splitDirection):
            print("split")
        case .Close:
            print("close")
        }
    }
}

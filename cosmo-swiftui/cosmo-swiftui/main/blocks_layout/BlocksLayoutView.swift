//
//  BlocksLayoutView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import SwiftUI

struct BlocksLayoutView: View {

    @ObservedObject var blocksLayout: BlocksLayout
    @ObservedObject var resizeHandler: BlocksResizeHandler
    @ObservedObject var splitHandler: BlocksSplitHandler

    var body: some View {

        let gloalDragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged({
            resizeHandler.globalBlockDrag = $0
        }).onEnded({ _ in
            resizeHandler.globalBlockDrag = nil
        })

        ZStack(alignment: .topLeading) {
            ForEach(blocksLayout.blocks, id: \.blockId) { block in
                BlockContainerView(container: BlockContainer(block, resizeHandler, splitHandler))
                .frame(
                    width: (block.width * resizeHandler.$homeSize.width.wrappedValue) + block.widthAdjustment,
                    height: (block.height * resizeHandler.$homeSize.height.wrappedValue) + block.heightAdjustment
                )
                .offset(
                    CGSize(
                        width: (block.widthOffset * resizeHandler.$homeSize.width.wrappedValue) + block.widthOffsetAdjustment,
                        height: (block.heightOffset * resizeHandler.$homeSize.height.wrappedValue) + block.heightOffsetAdjustment
                    )
                )
                .simultaneousGesture(gloalDragGesture)
            }

        }
    }
}

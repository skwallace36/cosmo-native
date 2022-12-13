//
//  BlocksSplitHandler.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import SwiftUI


class BlocksSplitHandler: ObservableObject {
    var blocksLayout: BlocksLayout
    @Binding var homeSize: CGSize

    init(_ homeSize: Binding<CGSize>, _ blocksLayout: BlocksLayout) {
        self._homeSize = homeSize
        self.blocksLayout = blocksLayout
    }
    @MainActor
    func splitBlock(_ direction: SplitDirection, block: Block) {
        switch direction {
        case .Horizontal:
            break
        case .Vertical:
            splitVertically(block)
        }

    }
    @MainActor
    func splitVertically(_ block: Block) {
        let newBlock = Block(
            blockId: blocksLayout.blocks.count + 1,
            blockType: .Empty,
            width: block.width * 0.5,
            height: block.height,
            widthOffset: block.widthOffset + (block.width * 0.5),
            heightOffset: block.heightOffset)


        block.rightNeighbors.forEach {
            // add original block right neighbors to new block right neighbors
            newBlock.rightNeighbors.append($0)
            // add new block to original block right neighbors left neighbors
            $0.leftNeighbors.append(newBlock)
            // remove original block from original right neighbors left neighbors
            $0.leftNeighbors.removeAll { $0.blockId == block.blockId }
        }
        // set original block right neighbors to new block
        block.rightNeighbors = [newBlock]
        //set new block left neighbors to original block
        newBlock.leftNeighbors.append(block)

        // need to recalculate same width neighbors

        // add new block to layout
        blocksLayout.blocks.append(newBlock)
        // set original block width to half of its original width
        block.width = block.width * 0.5
    }
}
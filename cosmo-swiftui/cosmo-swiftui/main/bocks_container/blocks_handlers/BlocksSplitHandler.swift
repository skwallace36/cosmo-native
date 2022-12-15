//
//  BlocksSplitHandler.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import SwiftUI

enum SplitDirection {
    case Horizontal
    case Vertical
}

enum BlockAction: Hashable {
    case Split(SplitDirection)

    var label: String {
        switch self {
        case .Split(let splitDirection):
            switch splitDirection {
            case .Horizontal:
                return "Split Horizontally"
            case .Vertical:
                return "Split Vertically"
            }
        }
    }
}

class BlocksSplitHandler: ObservableObject {
    @ObservedObject var blocksProvider: BlocksProvider
    @ObservedObject var homeSize: HomeSize

    init(homeSize: HomeSize, blocksProvider: BlocksProvider) {
        self.homeSize = homeSize
        self.blocksProvider = blocksProvider
    }
    @MainActor
    func splitBlock(_ direction: SplitDirection, block: Block) {
        switch direction {
        case .Horizontal:
            splitHorizontally(block)
        case .Vertical:
            splitVertically(block)
        }
    }
}

extension BlocksSplitHandler {

    @discardableResult
    @MainActor
    func splitHorizontally(_ block: Block) -> Bool {
        let newBlock = Block(
            blockId: blocksProvider.blocks.count + 1,
            blockType: .Empty,
            width: block.width,
            height: block.height * 0.5,
            widthOffset: block.widthOffset,
            heightOffset: block.heightOffset + (block.height * 0.5))

        block.bottomNeighbors.forEach {
            // add original block bottom neighbors to new block right neighbors
            newBlock.bottomNeighbors.append($0)
            // add newblock to original blocks bottom neighbors top neighbors
            $0.topNeighbors.append(newBlock)
            // remove original block from original bottom neighbors top neighbors
            $0.topNeighbors.removeAll { $0.blockId == block.blockId }
        }

        // set original block bottom neighbor to new block
        block.bottomNeighbors = [newBlock]
        // add original block to new block top neighbors
        newBlock.topNeighbors.append(block)

        // set new block horizontal neighbor relationships to same as original block
        block.leftNeighbors.forEach {
            newBlock.leftNeighbors.append($0)
            $0.rightNeighbors.append(newBlock)
        }

        block.rightNeighbors.forEach {
            newBlock.rightNeighbors.append($0)
            $0.leftNeighbors.append(newBlock)
        }
        // add to each other's same width and x
//        newBlock.topNeighborsSameWidthAndX.append(block)
//        block.bottomNeighborsSameWidthAndX.append(newBlock)

        blocksProvider.blocks.append(newBlock)
        block.height = block.height * 0.5
        return true
    }

    @discardableResult
    @MainActor
    func splitVertically(_ block: Block) -> Bool{
        let newBlock = Block(
            blockId: blocksProvider.blocks.count + 1,
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

        // set new block vertical neighbor relationships to the same as original block
        block.topNeighbors.forEach {
            newBlock.topNeighbors.append($0)
            $0.bottomNeighbors.append(newBlock)
        }
        block.bottomNeighbors.forEach {
            newBlock.bottomNeighbors.append($0)
            $0.topNeighbors.append(newBlock)
        }
//        newBlock.topNeighborsSameWidthAndX.append(contentsOf: block.topNeighborsSameWidthAndX)
//        newBlock.bottomNeighborsSameWidthAndX.append(contentsOf: block.bottomNeighborsSameWidthAndX)

        // TODO: handle same width and x splitting
        // if splitting a block with a top/bottom same widthandx neighbor,
        // they are no longer same widthandx neighbors


        // need to recalculate same width horizontal neighbors (not implemented)

        // add new block to layout
        blocksProvider.blocks.append(newBlock)
        // set original block width to half of its original width
        block.width = block.width * 0.5
        return true
    }
}

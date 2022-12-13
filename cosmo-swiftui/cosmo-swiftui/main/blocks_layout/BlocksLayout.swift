//
//  Blocks.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI

class BlocksLayout: ObservableObject {
    @Published var blocks: [Block] = []

    @Published var initialLayout: DecodableBlocks? = nil { didSet { setBlocksLayout() }}

    func setBlocksLayout() {
        // create decodable block objects from initial layout json
        guard let decodableBlocks = initialLayout?.blocksLayout else { return }

        // set blocksLayout
        blocks.append(contentsOf: decodableBlocks.map { Block.fromDecodableBlock($0) })

        // block block neighbors
        decodableBlocks.enumerated().forEach { index, decodableBlock in
            blocks[index].leftNeighbors = blocks.filter {
                decodableBlock.neighbors.left.firstIndex(of: $0.blockId) != nil
            }
            blocks[index].rightNeighbors = blocks.filter {
                decodableBlock.neighbors.right.firstIndex(of: $0.blockId) != nil
            }
            blocks[index].topNeighbors = blocks.filter {
                decodableBlock.neighbors.top.firstIndex(of: $0.blockId) != nil
            }
            blocks[index].bottomNeighbors = blocks.filter {
                decodableBlock.neighbors.bottom.firstIndex(of: $0.blockId) != nil
            }

            blocks[index].topNeighborsSameWidthAndX = blocks.filter {
                decodableBlock.neighbors.verticalSameWidthAndX?.up?.firstIndex(of: $0.blockId) != nil
            }

            blocks[index].bottomNeighborsSameWidthAndX = blocks.filter {
                decodableBlock.neighbors.verticalSameWidthAndX?.down?.firstIndex(of: $0.blockId) != nil
            }
        }
    }
//
//    func topNeighborsSameWidthAndXRecursive(for block: Block, with topNeighbors: [Block] ) -> [Block] {
//        let topNeighborsWithSameWithAndX = topNeighbors.filter {
//            $0.width == block.width && $0.widthOffset == block.widthOffset
//        }
//        return topNeighborsWithSameWithAndX + topNeighborsWithSameWithAndX.flatMap { topNeighborsSameWidthAndXRecursive(for: $0, with: $0.topNeighbors) }
//    }
//
//    func bottomNeighborsSameWidthAndXRecursive(for block: Block, with bottomNeighbors: [Block] ) -> [Block] {
//        let bottomNeighborsWithSameWithAndX = bottomNeighbors.filter {
//            $0.width == block.width && $0.widthOffset == block.widthOffset
//        }
//        return bottomNeighborsWithSameWithAndX + bottomNeighborsWithSameWithAndX.flatMap { bottomNeighborsSameWidthAndXRecursive(for: $0, with: $0.bottomNeighbors) }
//    }
}

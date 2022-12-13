//
//  Block.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI


extension Block: Equatable, Identifiable, Hashable {
    static func == (lhs: Block, rhs: Block) -> Bool {
        lhs.blockId == rhs.blockId

    }
    func hash(into hasher: inout Hasher) {hasher.combine(blockId) }
}

class Block: ObservableObject  {

    var blockId: Int
    var blockType: BlockType
    var backgroundColor: Color = .random

    @Published var leftNeighbors: [Block] = []
    @Published var rightNeighbors: [Block] = []
    @Published var topNeighbors: [Block] = []
    @Published var bottomNeighbors: [Block] = []

    @Published var topNeighborsSameWidthAndX: [Block] = []
    @Published var bottomNeighborsSameWidthAndX: [Block] = []

    @Published var width: CGFloat
    @Published var widthAdjustment: CGFloat = 0.0
    @Published var widthOffset: CGFloat
    @Published var widthOffsetAdjustment: CGFloat = 0.0

    @Published var height: CGFloat
    @Published var heightAdjustment: CGFloat = 0.0
    @Published var heightOffset: CGFloat
    @Published var heightOffsetAdjustment: CGFloat = 0.0

    init(blockId: Int, blockType: BlockType, width: Double, height: Double, widthOffset: CGFloat, heightOffset: CGFloat) {
        self.blockId = blockId
        self.blockType = blockType
        self.width = CGFloat(width)
        self.height = CGFloat(height)
        self.widthOffset = widthOffset
        self.heightOffset = heightOffset
    }
}


extension Block {
    func leftNeighborsLabel() -> String {
        let text = self.leftNeighbors.reduce(into: "", { acc, neighbor in
            acc = acc + "\(neighbor.blockId), "
        })
        return "left: " + text.dropLast(2)
    }

    func rightNeighborsLabel() -> String {
        let text = self.rightNeighbors.reduce(into: "", { acc, neighbor in
            acc = acc + "\(neighbor.blockId), "
        })
        return "right: " + text.dropLast(2)
    }

    func topNeighborsLabel() -> String {
        let text = self.topNeighbors.reduce(into: "", { acc, neighbor in
            acc = acc + "\(neighbor.blockId), "
        })
        return "top: " + text.dropLast(2)
    }

    func bottomNeighborsLabel() -> String {
        let text = self.bottomNeighbors.reduce(into: "", { acc, neighbor in
            acc = acc + "\(neighbor.blockId), "
        })
        return "bottom: " + text.dropLast(2)
    }

}

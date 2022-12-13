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
    func hash(into hasher: inout Hasher) { hasher.combine(blockId) }
}

class Block: ObservableObject  {

    var blockId: Int
    var blockType: BlockType
    var backgroundColor: Color = .random

    var leftNeighbors: [Block] = []
    var rightNeighbors: [Block] = []
    var topNeighbors: [Block] = []
    var bottomNeighbors: [Block] = []

    var topNeighborsSameWidthAndX: [Block] = []
    var bottomNeighborsSameWidthAndX: [Block] = []

    var edgesToBorder: [Edge] = [.top, .bottom, .trailing, .leading]

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



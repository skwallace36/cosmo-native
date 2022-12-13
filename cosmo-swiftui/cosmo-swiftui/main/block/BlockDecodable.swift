//
//  BlockDecodable.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/30/22.
//

import Foundation

struct DecodableBlock: Decodable {
    let blockId: Int
    let blockType: String?
    let size: DecodableSize
    let offset: DecodableOffset
    let neighbors: DecodableNeighbors
}

struct DecodableNeighbors: Decodable {
    let left, right, top, bottom: [Int]
    var topSameWidthAndX: [Int]? = nil
    var verticalSameWidthAndX: DecodableVerticalSameWithAndX?
}

struct DecodableVerticalSameWithAndX: Decodable {
    let up, down: [Int]?
}

struct DecodableSize: Decodable {
    let width: Double
    let height: Double
}

struct DecodableOffset: Decodable {
    let width: Double
    let height: Double
}

extension Block {
    static func fromDecodableBlock(_ decodableBlock: DecodableBlock) -> Block {
        return Block(
            blockId: decodableBlock.blockId,
            blockType: BlockType(string: decodableBlock.blockType ?? "Empty"),
            width: decodableBlock.size.width,
            height: decodableBlock.size.height,
            widthOffset: decodableBlock.offset.width,
            heightOffset: decodableBlock.offset.height
        )
    }
}

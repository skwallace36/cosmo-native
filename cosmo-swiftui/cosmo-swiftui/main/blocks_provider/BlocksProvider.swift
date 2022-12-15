//
//  Blocks.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI

class BlocksProvider: ObservableObject {
    @Published var blocks: [Block] = []

    init() {
        loadBlocks()
    }
}

extension BlocksProvider {
    func loadBlocks(from jsonFile: String = "ComplexLayoutOne") {
        var decodableBlocks: [DecodableBlock]?
        if let initialLayoutPath = Bundle.main.path(forResource: jsonFile, ofType: "json") {
            if let initialLayoutData = try? Data(contentsOf: URL(fileURLWithPath: initialLayoutPath)) {
                do {
                    decodableBlocks = try JSONDecoder().decode(DecodableBlocks.self, from: initialLayoutData).decodableBlocks
                } catch let error { print(error) }
            }

        }
        guard let decodableBlocks = decodableBlocks else { return }
        print(decodableBlocks)

        // set blocks
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
}


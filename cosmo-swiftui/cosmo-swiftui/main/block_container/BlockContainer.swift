//
//  BlockContainer.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import SwiftUI

class BlockContainer: ObservableObject {
    var block: Block
    var resizeHandler: BlocksResizeHandler
    var splitHandler: BlocksSplitHandler
    var blockActions: [BlockAction] = [.Split(.Horizontal), .Split(.Vertical)]

    init(_ block: Block, _ resizeHandler: BlocksResizeHandler, _ splitHandler: BlocksSplitHandler) {
        self.block = block
        self.resizeHandler = resizeHandler
        self.splitHandler = splitHandler
    }
}

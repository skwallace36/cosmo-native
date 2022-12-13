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
    var contextMenuActions: [BlockContainerContextMenuAction] = [.Split(.Horizontal), .Split(.Vertical), .Close]

    init(_ block: Block, _ resizeHandler: BlocksResizeHandler) {
        self.block = block
        self.resizeHandler = resizeHandler
    }
}

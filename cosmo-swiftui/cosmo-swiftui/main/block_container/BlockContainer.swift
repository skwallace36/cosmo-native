//
//  BlockContainer.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import SwiftUI

class BlockContainer: ObservableObject {
    var block: Block
    var blockActions: [BlockAction] = [.Split(.Horizontal), .Split(.Vertical)]

    init(_ block: Block) {
        self.block = block
    }
}

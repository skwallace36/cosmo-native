//
//  BlockView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/12/22.
//

import SwiftUI

struct BlockView: View {

    @StateObject var block: Block
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Rectangle()
                .fill(.black)
                .frame(
                    height: block.topNeighbors.count == 0 ? 4.0 : 2.0
                )
            HStack(alignment: .top, spacing: 0.0) {
                Rectangle()
                    .fill(.black)
                    .frame(
                        width: block.leftNeighbors.count == 0 ? 4.0 : 2.0
                    )
                switch block.blockType {
                case .List:
                    ListBlockView().frame(maxWidth: .infinity, maxHeight: .infinity)
                case .Empty:
                    Rectangle().fill(block.backgroundColor)
                        .contentShape(Rectangle())
                }
                Rectangle()
                    .fill(.black)
                    .frame(
                        width: block.rightNeighbors.count == 0 ? 4.0 : 2.0
                    )
            }
            Rectangle()
                .fill(.black)
                .frame(
                    height: block.bottomNeighbors.count == 0 ? 4.0 : 2.0
                )
        }

    }
}

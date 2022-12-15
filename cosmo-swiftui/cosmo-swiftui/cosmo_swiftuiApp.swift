//
//  cosmo_swiftuiApp.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/17/22.
//

import SwiftUI

class HomeSize: ObservableObject {
    @Published var width: CGFloat
    @Published var height: CGFloat

    init(_ width: CGFloat = 0.0, _ height: CGFloat = 0.0) {
        self.width = width
        self.height = height
    }
}

@main
struct cosmo_swiftuiApp: App {

    let homeSize = HomeSize()
    let blocksProvider = BlocksProvider()

    var body: some Scene {
        WindowGroup {
            BlocksContainerView(
                homeSize: homeSize,
                blocksProvider: blocksProvider,
                blocksResizeHandler: BlocksResizeHandler(homeSize, blocksProvider),
                blocksSplitHandler: BlocksSplitHandler(homeSize: homeSize, blocksProvider: blocksProvider)
            )
        }
    }
}


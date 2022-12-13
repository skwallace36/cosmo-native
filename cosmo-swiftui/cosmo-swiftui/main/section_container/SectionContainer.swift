//
//  SectionContainer.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import SwiftUI

class SectionContainer: ObservableObject {
    var section: Section
    var resizeHandler: SectionsResizeHandler
    var contextMenuActions: [SectionContainerContextMenuAction] = [.Split(.Horizontal), .Split(.Vertical), .Close]

    init(_ section: Section, _ resizeHandler: SectionsResizeHandler) {
        self.section = section
        self.resizeHandler = resizeHandler
    }
}

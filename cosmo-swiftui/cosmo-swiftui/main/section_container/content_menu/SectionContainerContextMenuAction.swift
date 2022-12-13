//
//  section_container_context_menu.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import SwiftUI

enum SplitDirection {
    case Horizontal
    case Vertical
}


enum SectionContainerContextMenuAction: Hashable {
    case Split(SplitDirection)
    case Close

    var label: String {
        switch self {
        case .Split(let splitDirection):
            switch splitDirection {
            case .Horizontal:
                return "Split Horizontally"
            case .Vertical:
                return "Split Vertically"
            }
        case .Close:
            return "Close"
        }
    }

    func button() -> any View {
        Button("itembutton") {
            print("action")
        }
    }


}


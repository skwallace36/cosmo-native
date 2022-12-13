//
//  SplitEnums.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import Foundation

enum SplitDirection {
    case Horizontal
    case Vertical

}

enum BlockAction: Hashable {
    case Split(SplitDirection)


    var label: String {
        switch self {
        case .Split(let splitDirection):
            switch splitDirection {
            case .Horizontal:
                return "Split Horizontally"
            case .Vertical:
                return "Split Vertically"
            }
        }
    }
}


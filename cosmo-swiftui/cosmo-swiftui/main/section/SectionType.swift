//
//  SectionType.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/12/22.
//

import Foundation

enum SectionType: String {
    case List
    case Empty
    init(string: String) {
        switch string.lowercased() {
        case "list": self = .List
        case "empty": self = .Empty
        default: self = .Empty
        }
    }
}

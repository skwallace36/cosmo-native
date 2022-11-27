//
//  Color+Extensions.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/23/22.
//

import SwiftUI

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

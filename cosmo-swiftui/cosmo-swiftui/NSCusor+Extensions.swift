//
//  NSCusor+Extensions.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/20/22.
//

import AppKit

extension NSCursor {
    func popThenPush() {
        NSCursor.pop()
        push()
    }
}

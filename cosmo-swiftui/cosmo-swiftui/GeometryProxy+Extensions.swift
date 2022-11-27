//
//  GeometryProxy+Extensions.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/21/22.
//

import SwiftUI

extension GeometryProxy {
    func adjustOrigin() -> CGPoint {
        let adjustedFrame = adjustedFrame()
        return CGPoint(x: adjustedFrame.minX, y: adjustedFrame.minY)
    }
    func adjustedFrame() -> NSRect {
        let globalFrame = frame(in: .global)
        return NSRect(x: globalFrame.minX - safeAreaInsets.leading,
                      y: globalFrame.minY - safeAreaInsets.top,
                      width: globalFrame.width - (safeAreaInsets.leading + safeAreaInsets.trailing),
                      height: globalFrame.height - (safeAreaInsets.top + safeAreaInsets.bottom))
    }
}


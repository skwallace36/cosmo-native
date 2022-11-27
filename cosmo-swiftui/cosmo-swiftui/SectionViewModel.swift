//
//  SectionViewModel.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/19/22.
//

import SwiftUI


class SectionViewModel: ObservableObject {
    let uuid = UUID();


    @Published var cursor: NSCursor?
    @Published var viewOrigin: CGPoint = .zero
    @Published var mouseLocation: CGPoint = .zero
    @Published var mouseOverView = false

    @Binding var homeSize: CGSize
    @Published var height: CGFloat?
    @Published var width: CGFloat?
    var initWidthMultiplier: CGFloat?
    var initHeightMultiplier: CGFloat?



    var canResize = false

    init(homeSize: Binding<CGSize>, initWidthMultiplier: CGFloat? = nil, initHeightMultiplier: CGFloat? = nil) {
        self._homeSize = homeSize
        self.initWidthMultiplier = initWidthMultiplier
        self.initHeightMultiplier = initHeightMultiplier
    }

    func hoverActive(location: CGPoint) {
        mouseOverView = true
        mouseLocation = location
        setCursor()
    }

    func hoverEnded() {
        mouseOverView = false
        setCursor()
    }

    func setCursor() {
        guard let width = width, let height = height else {
            cursor = NSCursor.arrow
            return
        }
        if viewOrigin.x + width != homeSize.width {
            guard mouseLocation.x < height - 5 else {
                cursor = NSCursor.resizeLeftRight
                canResize = true
                return
            }
        }
        if viewOrigin.x != 0 {
            guard mouseLocation.x > 5 else {
                cursor = NSCursor.resizeLeftRight
                canResize = true
                return
            }
        }
        if viewOrigin.y != 0 {
            guard mouseLocation.y > 5 else {
                cursor = NSCursor.resizeUpDown
                canResize = true
                return
            }
        }
        guard mouseLocation.y < height - 5 else {
            cursor = NSCursor.resizeUpDown
            canResize = true
            return
        }
//        canResize = false
        cursor = NSCursor.arrow
    }

}


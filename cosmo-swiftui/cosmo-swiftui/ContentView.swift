//
//  ContentView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/17/22.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var appDelegate: AppDelegate


    var body: some View {
        HomeView()
    }
}

extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentRect(forFrameRect: frame).height
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

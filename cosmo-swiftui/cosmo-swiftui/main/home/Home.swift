//
//  HomeView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/19/22.
//

import SwiftUI


struct HomeView: View {

    @State var homeSize: CGSize = .zero

    var initialLayout: DecodableBlocks?
    var blocks: Blocks
    init() {
        var decodableBlocks: DecodableBlocks?
        if let initialLayoutPath = Bundle.main.path(forResource: "ComplexLayoutOne", ofType: "json") {
            if let initialLayoutData = try? Data(contentsOf: URL(fileURLWithPath: initialLayoutPath)) {
                do {
                    decodableBlocks = try JSONDecoder().decode(DecodableBlocks.self, from: initialLayoutData)
                } catch let error { print(error) }
            }

        }
        initialLayout = decodableBlocks
        blocks = Blocks(initialLayout: initialLayout)
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                BlocksView(
                    blocks: blocks, resizeHandler: BlocksResizeHandler(homeSize: $homeSize, blocks: blocks), homeSize: $homeSize
                )
            }
        }.bindGeometry(to: $homeSize) { $0.size }
    }
}


public extension View {
    func bindGeometry(to binding: Binding<CGSize>, reader: @escaping (GeometryProxy) -> CGSize) -> some View {
        self.background(GeometryBinding(reader: reader))
            .onPreferenceChange(GeometryPreference.self) { binding.wrappedValue = $0 }
    }
}

private struct GeometryBinding: View {
    let reader: (GeometryProxy) -> CGSize

    var body: some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: GeometryPreference.self,
                value: self.reader(geo)
            )
        }
    }
}

private struct GeometryPreference: PreferenceKey {

    typealias Value = CGSize

    static var defaultValue = CGSize.zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = CGSize(width: value.width + nextValue().width, height: value.height + nextValue().height)
    }
}

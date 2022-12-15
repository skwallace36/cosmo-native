//
//  HomeView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/19/22.
//

import SwiftUI



struct BlocksContainerView: View {

    @ObservedObject var homeSize: HomeSize
    @ObservedObject var blocksProvider: BlocksProvider
    @ObservedObject var blocksResizeHandler: BlocksResizeHandler
    @ObservedObject var blocksSplitHandler: BlocksSplitHandler

    init(homeSize: HomeSize, blocksProvider: BlocksProvider, blocksResizeHandler: BlocksResizeHandler, blocksSplitHandler: BlocksSplitHandler) {
        self.homeSize = homeSize
        self.blocksProvider = blocksProvider
        self.blocksResizeHandler = blocksResizeHandler
        self.blocksSplitHandler = blocksSplitHandler
    }

    var body: some View {

        let gloalDragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged({
            blocksResizeHandler.globalBlockDrag = $0
        }).onEnded({ _ in
            blocksResizeHandler.globalBlockDrag = nil
        })

        GeometryReader { geo in
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    ForEach(blocksProvider.blocks, id: \.blockId) { block in
                        BlockContainerView(container: BlockContainer(block), blocksResizeHandler: blocksResizeHandler, blocksSplitHandler: blocksSplitHandler)
                        .frame(
                            width: (block.width * homeSize.width) + block.widthAdjustment,
                            height: (block.height * homeSize.height) + block.heightAdjustment
                        )
                        .offset(
                            CGSize(
                                width: (block.widthOffset * homeSize.width) + block.widthOffsetAdjustment,
                                height: (block.heightOffset * homeSize.height) + block.heightOffsetAdjustment
                            )
                        )
                        .simultaneousGesture(gloalDragGesture)
//                        .environmentObject()
                    }

                }
            }.onChange(of: geo.size) {
                homeSize.height = $0.height
                homeSize.width = $0.width
            }
        }.environmentObject(blocksResizeHandler)
            
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

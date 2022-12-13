//
//  SectionContainer.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/5/22.
//

import SwiftUI

struct SectionContainerView: View {
    @StateObject var container: SectionContainer
    var section: Section { container.section }
    var resizeHandler: SectionsResizeHandler { container.resizeHandler }
    
    var body: some View {
        let localDrag = DragGesture(minimumDistance: 3, coordinateSpace: .named("section")).onChanged({
            resizeHandler.startSection = section
            resizeHandler.localSectionDrag = $0
        }).onEnded({ _ in
            resizeHandler.localSectionDrag = nil
        })
        SectionView(section: section, resizeHandler: resizeHandler)
        .overlay {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(localDrag)
                .coordinateSpace(name: "section")
                .contextMenu {
                    ForEach(container.contextMenuActions, id: \.self) { action in
                        Button(action.label, action: {
                            
                        })
                    }

                }
        }
        .onContinuousHover { phase in
            resizeHandler.sectionHovering = section
            resizeHandler.sectionHover = phase
        }
    }
}

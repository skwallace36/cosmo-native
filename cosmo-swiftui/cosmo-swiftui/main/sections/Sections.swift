//
//  Sections.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI

class Sections: ObservableObject {
    @Published var sections: [Section] = []

    var initialLayout: DecodableSections? = nil

    init(initialLayout: DecodableSections?) {

        // create decodable section objects from initial layout json
        guard let decodableSections = initialLayout?.sections else { return }

        // set sections
        sections.append(contentsOf: decodableSections.map { Section.fromDecodableSection($0) })

        // section section neighbors
        decodableSections.enumerated().forEach { index, decodableSection in
            sections[index].leftNeighbors = sections.filter {
                decodableSection.neighbors.left.firstIndex(of: $0.sectionId) != nil
            }
            sections[index].rightNeighbors = sections.filter {
                decodableSection.neighbors.right.firstIndex(of: $0.sectionId) != nil
            }
            sections[index].topNeighbors = sections.filter {
                decodableSection.neighbors.top.firstIndex(of: $0.sectionId) != nil
            }
            sections[index].bottomNeighbors = sections.filter {
                decodableSection.neighbors.bottom.firstIndex(of: $0.sectionId) != nil
            }

            sections[index].topNeighborsSameWidthAndX = sections.filter {
                decodableSection.neighbors.verticalSameWidthAndX?.up?.firstIndex(of: $0.sectionId) != nil
            }

            sections[index].bottomNeighborsSameWidthAndX = sections.filter {
                decodableSection.neighbors.verticalSameWidthAndX?.down?.firstIndex(of: $0.sectionId) != nil
            }
        }
    }

    func topNeighborsSameWidthAndXRecursive(for section: Section, with topNeighbors: [Section] ) -> [Section] {
        let topNeighborsWithSameWithAndX = topNeighbors.filter {
            $0.width == section.width && $0.widthOffset == section.widthOffset
        }
        return topNeighborsWithSameWithAndX + topNeighborsWithSameWithAndX.flatMap { topNeighborsSameWidthAndXRecursive(for: $0, with: $0.topNeighbors) }
    }

    func bottomNeighborsSameWidthAndXRecursive(for section: Section, with bottomNeighbors: [Section] ) -> [Section] {
        let bottomNeighborsWithSameWithAndX = bottomNeighbors.filter {
            $0.width == section.width && $0.widthOffset == section.widthOffset
        }
        return bottomNeighborsWithSameWithAndX + bottomNeighborsWithSameWithAndX.flatMap { bottomNeighborsSameWidthAndXRecursive(for: $0, with: $0.bottomNeighbors) }
    }
}

struct SectionsView: View {

    @StateObject var sections: Sections
    @StateObject var resizeHandler: SectionsResizeHandler

    @Binding var homeSize: CGSize

    var body: some View {

        let gloalDragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged({
            resizeHandler.globalSectionDrag = $0
        }).onEnded({ _ in
            resizeHandler.globalSectionDrag = nil
        })

        ZStack(alignment: .topLeading) {
            ForEach(sections.sections, id: \.sectionId) { section in
                SectionContainerView(container: SectionContainer(section, resizeHandler))
                .frame(
                    width: (section.width * $homeSize.width.wrappedValue) + section.widthAdjustment,
                    height: (section.height * $homeSize.height.wrappedValue) + section.heightAdjustment
                )
                .offset(
                    CGSize(
                        width: (section.widthOffset * homeSize.width) + section.widthOffsetAdjustment,
                        height: (section.heightOffset * homeSize.height) + section.heightOffsetAdjustment
                    )
                )
                .simultaneousGesture(gloalDragGesture)
            }

        }
    }
}

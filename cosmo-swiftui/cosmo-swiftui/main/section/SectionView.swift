//
//  SectionView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/12/22.
//

import SwiftUI

struct SectionView: View {

    @StateObject var section: Section
    var resizeHandler: SectionsResizeHandler
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Rectangle()
                .fill(.black)
                .frame(
                    height: section.topNeighbors.count == 0 ? 4.0 : 2.0
                )
            HStack(alignment: .top, spacing: 0.0) {
                Rectangle()
                    .fill(.black)
                    .frame(
                        width: section.leftNeighbors.count == 0 ? 4.0 : 2.0
                    )
                switch section.sectionType {
                case .List:
                    ListSectionView().frame(maxWidth: .infinity, maxHeight: .infinity)
                case .Empty:
                    Rectangle().fill(section.backgroundColor)
                        .contentShape(Rectangle())
                }
                Rectangle()
                    .fill(.black)
                    .frame(
                        width: section.rightNeighbors.count == 0 ? 4.0 : 2.0
                    )
            }
            Rectangle()
                .fill(.black)
                .frame(
                    height: section.bottomNeighbors.count == 0 ? 4.0 : 2.0
                )
        }

    }
}

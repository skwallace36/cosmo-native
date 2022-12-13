//
//  ListBlock.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/3/22.
//

import SwiftUI


class ListBlock: ObservableObject {
    @Published var columns = [GridItem(.adaptive(minimum: 20.0), alignment: .topLeading)]
    @Published var rows = [
        ListRow(0, "row1", checked: false),
        ListRow(1, "row2", checked: true),
        ListRow(2, "row3", checked: false)
    ]
    @Published var rowTapped: ListRow?
}

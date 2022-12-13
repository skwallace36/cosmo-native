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

struct ListBlockView: View {

    @StateObject var listBlock = ListBlock()


    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(listBlock.rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Text(row.text)
                        }.padding(.horizontal, 8)
                        Spacer()
                    }.frame(minHeight: 44).background(.gray).cornerRadius(4)

                }
                Spacer()
            }.padding(8)
        }.background(.purple)
    }
}

enum CheckedState {
    case Unchecked
    case Checked
}


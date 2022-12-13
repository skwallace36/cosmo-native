//
//  ListBlockView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/13/22.
//

import SwiftUI

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


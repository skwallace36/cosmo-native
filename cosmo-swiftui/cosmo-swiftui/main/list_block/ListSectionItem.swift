//
//  ListBlockItem.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/5/22.
//

import SwiftUI

//class ListRow: ObservableObject, Equatable, Hashable {
//    static func == (lhs: ListRow, rhs: ListRow) -> Bool { lhs.row == rhs.row }
//
//    func hash(into hasher: inout Hasher) { hasher.combine(row) }
//
//    var row: Int
//    @Published var checked: Bool
//    @Published var text: String
//
//    init(_ row: Int, _ text: String, checked: Bool) {
//        self.row = row
//        self.text = text
//        self.checked = checked
//    }
//}
//
//struct ListRowView: View {
//    @StateObject var listRow: ListRow
//    @Binding var rowTapped: ListRow?
//
//    var body: some View {
//        HStack {
//            CheckCircle (
//                checked: $listRow.checked
////                imageName: listRow.checked ? "checkmark.circle" : "circle"
//            ).onTapGesture {
//                listRow.checked.toggle()
//                rowTapped = listRow
//            }
//
//            TextField("list row text", text: $listRow.text)
//                .tint(.green)
//                .focusable(false)
//                .textFieldStyle(.plain)
//                .foregroundColor(.black)
//                .font(Font.system(size: 18).monospaced())
//                .onTapGesture {
//                    print("text tapped")
//                }
//
//            Spacer()
//        }.frame(minHeight: 32)
//    }
//}

//
//  Sections.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI

class Sections: ObservableObject {

    @Published var rows: [[Section]] = []
    

    func leftNeighbor(for section: Section?) -> Section? {
        guard let section = section else { return nil }
        guard let row = rows.firstIndex(where: { $0.contains(section) }) else { return nil }
        guard let col = rows[row].firstIndex(where: { $0.uuid == section.uuid }) else { return nil }
        guard col != 0 else { return nil }
        return rows[row][col - 1]
    }

    func rightNeighbor(for section: Section?) -> Section? {
        guard let section = section else { return nil }
        guard let row = rows.firstIndex(where: { $0.contains(section) }) else { return nil }
        guard let col = rows[row].firstIndex(where: { $0.uuid == section.uuid }) else { return nil }
        guard col != rows[row].count - 1 else { return nil }
        return rows[row][col + 1]
    }

    func leftNeighbors(for section: Section?) -> [Section] {
        guard let section = section else { return [] }
        guard let row = rows.firstIndex(where: { $0.contains(section) }) else { return [] }
        guard let col = rows[row].firstIndex(where: { $0.uuid == section.uuid }) else { return [] }
        return rows[row].dropLast(rows[row].count - col)
    }

    func rightNeighbors(for section: Section?) -> [Section] {
        guard let section = section else { return [] }
        guard let row = rows.firstIndex(where: { $0.contains(section) }) else { return [] }
        guard let col = rows[row].firstIndex(where: { $0.uuid == section.uuid }) else { return [] }
        return Array<Section>(rows[row].dropFirst(col + 1))
    }

//    func bottomNeighbor(for section: Section?) -> Section? {
//        guard let section = section else { return nil }
//        guard let row = rows.firstIndex(where: { $0.contains(section) }) else { return nil }
//        if row == rows.count - 1 { return nil }
//        guard let col = rows[row].firstIndex(where: { $0.uuid == section.uuid }) else { return nil }
//        for section in rows[row + 1] {
//            print(section)
//        }
//        return nil
//    }
}

class MouseHover: ObservableObject, Equatable {
    static func == (lhs: MouseHover, rhs: MouseHover) -> Bool {
        return (lhs.location == rhs.location && lhs.section?.uuid == rhs.section?.uuid)
    }

    @Published var section: Section?
    @Published var location: CGPoint?

    init(_ section: Section?, _ location: CGPoint?) {
        self.section = section
        self.location = location
    }

    func update(with section: Section?, and location: CGPoint?) {
        self.section = section
        self.location = location
    }
}

enum ResizeEdge {
    case Left
    case Right
    case Top
    case Bottom
}

struct SectionsView: View {

    @StateObject var sections: Sections
    @ObservedObject var mouseHover = MouseHover(nil, nil)
    @Binding var homeSize: CGSize
    @State var canResizeSection = false
    @State var resizingSections = false
    @State var mouseDownWindowLocation: CGPoint?
    @State var resizingSection: Section?
    @State var resizingFromEdge: ResizeEdge?
    let resizeThreshold: CGFloat = 5.0

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<sections.rows.count, id: \.self) { row in
                ForEach(0..<sections.rows[row].count, id: \.self) { col in
                    SectionView(section: sections.rows[row][col], homeSize: $homeSize, resizing: $resizingSections, mouseHover: mouseHover)
                        .offset(
                            CGSize(
                                width: 0,
                                height: 0
                            )
                        )
                }
            }.onAppear(perform: {
                NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) {
                    mouseDownWindowLocation = $0.locationInWindow
                    if canResizeSection {
                        resizingSection = mouseHover.section
                        resizingSections = true
                    }
                    return $0
                }
                NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) {
                    resizingSection = nil
                    resizingSections = false
                    mouseDownWindowLocation = nil
                    return $0
                }
                NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged]) {
                    if resizingSections, let mouseDownLocation = self.mouseDownWindowLocation {
                        let dX = $0.locationInWindow.x - mouseDownLocation.x
                        let dY = mouseDownLocation.y - $0.locationInWindow.y
                        switch resizingFromEdge {
                        case .Left:
                            if dX > 0 {
                                resizingSection?.leftNeighbors.forEach { $0.widthOffset = dX }
                                resizingSection?.leftNeighbors.forEach { $0.rightNeighbors.forEach { $0.widthOffset = -dX } }
                            } else if dX < 0 {
                                resizingSection?.leftNeighbors.forEach { $0.widthOffset = dX }
                                resizingSection?.leftNeighbors.forEach { $0.rightNeighbors.forEach { $0.widthOffset = -dX } }
                            }

                        case .Right:
                            if dX > 0 {
                                resizingSection?.rightNeighbors.forEach { $0.widthOffset = -dX }
                                resizingSection?.rightNeighbors.forEach { $0.leftNeighbors.forEach { $0.widthOffset = dX } }
                            } else if dX < 0 {
                                resizingSection?.rightNeighbors.forEach { $0.widthOffset = -dX }
                                resizingSection?.rightNeighbors.forEach { $0.leftNeighbors.forEach { $0.widthOffset = dX } }
                            }
                        case.Top:
                            if dY > 0 {
                                resizingSection?.topNeighbors.forEach { $0.heightOffset = dY }
                                resizingSection?.topNeighbors.forEach { $0.bottomNeighbors.forEach { $0.heightOffset = -dY } }
                            } else if dY < 0 {
                                resizingSection?.topNeighbors.forEach { $0.heightOffset = dY }
                                resizingSection?.topNeighbors.forEach { $0.bottomNeighbors.forEach { $0.heightOffset = -dY } }
                            }
                        case .Bottom:
                            if dY > 0 {
                                resizingSection?.bottomNeighbors.forEach { $0.heightOffset = -dY }
                                resizingSection?.bottomNeighbors.forEach { $0.topNeighbors.forEach { $0.heightOffset = dY } }
                            } else if dY < 0 {
                                resizingSection?.bottomNeighbors.forEach { $0.heightOffset = -dY }
                                resizingSection?.bottomNeighbors.forEach { $0.topNeighbors.forEach { $0.heightOffset = dY } }
                            }
                        case .none:
                            break;
                        }

                    }
                    return $0
                }
            })
            .onChange(of: mouseHover.location, perform: { _ in
                handleHover()
            })
        }
    }

    func handleHover() {
        guard let section = mouseHover.section, let location = mouseHover.location else { return }
        canResizeSection = true
        if !section.farLeft && location.x < resizeThreshold {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            resizingFromEdge = .Left
        } else if !section.farRight && location.x > section.width - resizeThreshold {
            if NSCursor.current != NSCursor.resizeLeftRight { NSCursor.resizeLeftRight.popThenPush() }
            resizingFromEdge = .Right
        } else if !section.top && location.y < resizeThreshold {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            resizingFromEdge = .Top
        } else if !section.bottom && location.y > section.height - resizeThreshold {
            if NSCursor.current != NSCursor.resizeUpDown { NSCursor.resizeUpDown.popThenPush() }
            resizingFromEdge = .Bottom
        } else {
            resizingFromEdge = .none
            canResizeSection = false
            NSCursor.arrow.popThenPush()
        }
    }
}



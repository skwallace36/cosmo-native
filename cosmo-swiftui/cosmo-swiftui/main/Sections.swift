//
//  Sections.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI

class Sections: ObservableObject {

    @Published var sections: [Section] = []

//    func cumulativeLeftWidthMultiplier(section: Section?) -> CGFloat {
//        guard let section = section else { return 0.0 }
//        guard section.leftNeighbors.count != 0 else { return 0.0 }
//        let widest = section.leftNeighbors.max(by: {$0.widthMutiplier > $1.widthMutiplier} )
//        return (widest?.widthMutiplier ?? 0) + cumulativeLeftWidthMultiplier(section: widest)
//    }
//
//    func tempCumulativeLeftWidthMultiplier(section: Section?) -> CGFloat {
//        guard let section = section else { return 0.0 }
//        guard section.leftNeighbors.count != 0 else { return 0.0 }
//        guard let widest = section.leftNeighbors.max(by: {$0.widthMutiplier > $1.widthMutiplier} ) else { return 0.0}
//        return (widest.width / (widest.homeSize?.wrappedValue.width ?? 0)) + tempCumulativeLeftWidthMultiplier(section: widest)
//    }
//
//    func cumulativeTopHeightMultiplier(section: Section?) -> CGFloat {
//        guard let section = section else { return 0.0 }
//        guard section.topNeighbors.count != 0 else { return 0.0 }
//        let tallest = section.topNeighbors.max(by: {$0.heightOffset > $1.heightOffset} )
//        return (tallest?.heightMultiplier ?? 0) + cumulativeTopHeightMultiplier(section: tallest)
//    }
//
    func setZStackOffsets() {
        for section in sections {
            section.heightZStackOffset = section.cumulativeTopHeightMultiplier(section: section)
            section.widthZStackOffset = section.cumulativeLeftWidthMultiplier(section: section)
        }
    }
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

    func widthOffset(for section: Section) -> CGFloat {
        guard section.leftNeighbors.count > 0 else { return .zero}
        return 0
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(sections.sections) { section in
                SectionView(section: section, homeSize: $homeSize, resizing: $resizingSections, mouseHover: mouseHover)
                    .offset(
                        CGSize(
                            width: section.widthZStackOffset * homeSize.width,
                            height: section.heightZStackOffset * homeSize.height
                        )
                    )

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
                    sections.setZStackOffsets()
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
                        for section in sections.sections {
                            section.widthZStackOffset = section.cumulativeLeftWidthMultiplier(section: section)
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



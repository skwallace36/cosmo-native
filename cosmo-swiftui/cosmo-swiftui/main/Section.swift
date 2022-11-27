//
//  Section.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI


class Section: ObservableObject, Equatable, Identifiable  {
    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.uuid == rhs.uuid
    }

    @Published var widthZStackOffset = 0.0
    @Published var heightZStackOffset = 0.0

    var leftNeighbor: Section? = nil
    var rightNeighbor: Section? = nil
    var topNeighbor: Section? = nil
    var bottomNeighbor: Section? = nil

    var leftNeighbors: [Section] = []
    var rightNeighbors: [Section] = [] {
        didSet {
            let difference = rightNeighbors.difference(from: oldValue)
            for change in difference {
              switch change {
              case .remove:
                  break;
              case let .insert(_, newElement, _):
                  newElement.leftNeighbors.append(self)
              }
            }
        }
    }
    var topNeighbors: [Section] = []
    var bottomNeighbors: [Section] = [] {
        didSet {
            let difference = bottomNeighbors.difference(from: oldValue)
            for change in difference {
              switch change {
              case .remove:
                  break;
              case let .insert(_, newElement, _):
                  newElement.topNeighbors.append(self)
              }
            }
        }
    }

    @Published var widthMutiplier: CGFloat
    @Published var heightMultiplier: CGFloat
    @Published var widthOffset: CGFloat = 0.0
    @Published var heightOffset = CGFloat.zero
    var homeSize: Binding<CGSize>? = nil
    var width: CGFloat { (homeSize?.wrappedValue.width ?? 0) * widthMutiplier + widthOffset }
    var height: CGFloat { (homeSize?.wrappedValue.height ?? 0) * heightMultiplier + heightOffset }
    var farLeft: Bool
    var farRight: Bool
    var top: Bool
    var bottom: Bool
    var uuid = UUID()
    var title: String
    var backgroundColor: Color = .random
    init(_ widthMultiplier: Double, _ heightMultiplier: Double, farLeft: Bool = false, farRight: Bool = false, top: Bool = false, bottom: Bool = false, title: String) {
        self.widthMutiplier = CGFloat(widthMultiplier)
        self.heightMultiplier = CGFloat(heightMultiplier)
        self.farLeft = farLeft
        self.farRight = farRight
        self.top = top
        self.bottom = bottom
        self.title = title
    }

    func cumulativeLeftWidthMultiplier(section: Section?) -> CGFloat {
        guard let section = section else { return 0.0 }
        guard section.leftNeighbors.count != 0 else { return 0.0 }
        guard let widest = section.leftNeighbors.max(by: { $0.width / (homeSize?.wrappedValue.width ?? 0) > $1.width / (homeSize?.wrappedValue.width ?? 0) } ) else { return 0.0 }
        return (widest.width  / (homeSize?.wrappedValue.width ?? 0)) + cumulativeLeftWidthMultiplier(section: widest)
    }
    func cumulativeTopHeightMultiplier(section: Section?) -> CGFloat {
        guard let section = section else { return 0.0 }
        guard section.topNeighbors.count != 0 else { return 0.0 }
        let tallest = section.topNeighbors.max(by: {$0.heightOffset > $1.heightOffset} )
        return (tallest?.heightMultiplier ?? 0) + cumulativeTopHeightMultiplier(section: tallest)
    }

}

struct SectionView: View {

    @StateObject var section: Section

    @Binding var homeSize: CGSize
    @Binding var resizing: Bool
    var mouseHover: MouseHover

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
            Text("\(section.title)")
            }
        }.frame(
            width: section.widthMutiplier * homeSize.width + section.widthOffset,
            height: section.heightMultiplier * homeSize.height + section.heightOffset
        )
            .background(section.backgroundColor)
            .onContinuousHover(perform: { phase in
                switch phase {
                case .active(let location):
                    mouseHover.update(with: section, and: location)
                case .ended:
                    break
                }
            })
            .onAppear(perform: {
                section.homeSize = $homeSize
            })
            .onChange(of: resizing, perform: { [resizing] newValue in
                // end of resize
                section.widthZStackOffset = section.cumulativeLeftWidthMultiplier(section: section)
                if resizing && !newValue {
                    let newWidth = section.width
                    section.widthMutiplier = newWidth / homeSize.width
                    section.widthOffset = 0
                    section.widthZStackOffset = section.cumulativeLeftWidthMultiplier(section: section)
                    let newHeight = section.height
                    section.heightMultiplier = newHeight / homeSize.height
                    section.heightOffset = 0
                }
            })
    }

    func handleHomeSizeChange(_ newSize: CGSize) {

        print(newSize)
    }
}


extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

//
//  Section.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/24/22.
//

import SwiftUI


class Section: ObservableObject, Equatable {
    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.uuid == rhs.uuid
    }

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
    var backgroundColor: Color = .random
    init(_ widthMultiplier: Double, _ heightMultiplier: Double, farLeft: Bool = false, farRight: Bool = false, top: Bool = false, bottom: Bool = false) {
        self.widthMutiplier = CGFloat(widthMultiplier)
        self.heightMultiplier = CGFloat(heightMultiplier)
        self.farLeft = farLeft
        self.farRight = farRight
        self.top = top
        self.bottom = bottom
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
                Text("Hello, world!")
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
                if resizing && !newValue {
                    let newWidth = section.width
                    section.widthMutiplier = newWidth / homeSize.width
                    section.widthOffset = 0
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

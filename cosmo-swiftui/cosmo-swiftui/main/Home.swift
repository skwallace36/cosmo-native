//
//  HomeView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/19/22.
//

import SwiftUI




class Home: ObservableObject {
    @Published var sections = Sections()
}


struct HomeView: View {

    @Environment(\.scenePhase)var scenePhase
    @StateObject var home = Home()
    @State var homeSize: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                SectionsView(sections: home.sections, homeSize: $homeSize)
            }.onChange(of: scenePhase) { phase in
                if phase == .active {
                    let sectionOne = Section(0.25, 0.7, farLeft: true, top: true, title: "sectionOne")
                    let sectionTwo = Section(0.375, 0.7, top: true, title: "sectionTwo")
                    let sectionThree = Section(0.375, 0.7, farRight: true, top: true, title: "sectionThree")
                    let sectionFour = Section(1, 0.3, farLeft: true, farRight: true, bottom: true, title: "sectionFour")
                    [sectionOne, sectionTwo, sectionThree].forEach({ $0.bottomNeighbors.append(sectionFour) })
                    sectionFour.topNeighbors.append(contentsOf: [sectionOne, sectionTwo, sectionThree])
                    sectionOne.rightNeighbors.append(sectionTwo)
                    sectionTwo.rightNeighbors.append(sectionThree)
                    home.sections.sections.append(contentsOf: [sectionOne, sectionTwo, sectionThree, sectionFour])
                    home.sections.setZStackOffsets()
                }
            }
        }
        .bindGeometry(to: $homeSize) { $0.size }
    }
}


public extension View {
    func bindGeometry(
        to binding: Binding<CGSize>,
        reader: @escaping (GeometryProxy) -> CGSize) -> some View {
        self.background(GeometryBinding(reader: reader))
            .onPreferenceChange(GeometryPreference.self) {
                binding.wrappedValue = $0
        }
    }
}

private struct GeometryBinding: View {

    let reader: (GeometryProxy) -> CGSize

    var body: some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: GeometryPreference.self,
                value: self.reader(geo)
            )
        }
    }
}

private struct GeometryPreference: PreferenceKey {

    typealias Value = CGSize

    static var defaultValue = CGSize.zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = CGSize(width: value.width + nextValue().width, height: value.height + nextValue().height)
    }
}

//
//  HomeView.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/19/22.
//

import SwiftUI


struct HomeView: View {

    @State var homeSize: CGSize = .zero
    var initialLayout: DecodableSections? {
//        guard let initialLayoutPath = Bundle.main.path(forResource: "ThreeColumns", ofType: "json") else { return nil }
//        guard let initialLayoutPath = Bundle.main.path(forResource: "ComplexLayoutTwo", ofType: "json") else { return nil }

        var decodableSections: DecodableSections?

        guard let initialLayoutPath = Bundle.main.path(forResource: "ComplexLayoutOne", ofType: "json") else {
            print("failed to load initialLayoutPath: ComplexLayoutOne")
            return nil
        }
        guard let initialLayoutData = try? Data(contentsOf: URL(fileURLWithPath: initialLayoutPath)) else {
            print("failed to create initialLayoutData for path: \(initialLayoutPath)")
            return nil
        }
        do {
            decodableSections = try JSONDecoder().decode(DecodableSections.self, from: initialLayoutData)
        } catch let error { print(error) }
        return decodableSections
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                SectionsView(
                    sections: Sections(initialLayout: initialLayout), homeSize: $homeSize
                )
            }
        }.bindGeometry(to: $homeSize) { $0.size }
    }
}


public extension View {
    func bindGeometry(to binding: Binding<CGSize>, reader: @escaping (GeometryProxy) -> CGSize) -> some View {
        self.background(GeometryBinding(reader: reader))
            .onPreferenceChange(GeometryPreference.self) { binding.wrappedValue = $0 }
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

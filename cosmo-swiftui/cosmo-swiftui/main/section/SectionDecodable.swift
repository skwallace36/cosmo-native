//
//  SectionDecodable.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/30/22.
//

import Foundation

struct DecodableSection: Decodable {
    let sectionId: Int
    let size: DecodableSize
    let offset: DecodableOffset
    let neighbors: DecodableNeighbors
}

struct DecodableNeighbors: Decodable {
    let left, right, top, bottom: [Int]
    var topSameWidthAndX: [Int]? = nil
    var verticalSameWidthAndX: DecodableVerticalSameWithAndX?
}

struct DecodableVerticalSameWithAndX: Decodable {
    let up, down: [Int]?
}

struct DecodableSize: Decodable {
    let width: Double
    let height: Double
}

struct DecodableOffset: Decodable {
    let width: Double
    let height: Double
}

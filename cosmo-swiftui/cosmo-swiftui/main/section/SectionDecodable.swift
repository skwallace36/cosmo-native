//
//  SectionDecodable.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/30/22.
//

import Foundation

struct DecodableSection: Decodable {
    let id: Int
    let size: DecodableSize
    let offset: DecodableOffset
    let neighbors: DecodableNeighbors
}

// MARK: - Neighbors
struct DecodableNeighbors: Decodable {
    let left, right, top, bottom: [Int]
}

// MARK: - Size
struct DecodableSize: Decodable {
    let width: Double
    let height: Double
}

// MARK: - Offset
struct DecodableOffset: Decodable {
    let width: Double
    let height: Double
}

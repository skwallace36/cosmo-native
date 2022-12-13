//
//  BlockBorder.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 12/3/22.
//

import SwiftUI

struct BlockBorder: Shape {

    var width: CGFloat
    var trailing: Edge?
    var bottom: Edge?

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in [Edge.leading, trailing, Edge.top, bottom].compactMap({$0}) {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

//
//  ContentBuilder.swift
//  
//
//  Created by Metin Tarık Kiki on 30.09.2024.
//

import SwiftUI

enum ContentBuilder {
    
    static func build<BuiltContent: View>(@ViewBuilder content: () -> BuiltContent) -> BuiltContent {
        content()
    }
    
    static func alignCellForVGridItem<CellView: View>(
        view: CellView,
        gridItem: GridItem
    ) -> some View {
        build {
            switch gridItem.size {
            case .fixed(let size):
                view
                    .frame(
                        width: size,
                        alignment: gridItem.alignment ?? .center
                    )
            case .flexible(let minimum, let maximum):
                view
                    .frame(
                        minWidth: minimum,
                        maxWidth: maximum,
                        alignment: gridItem.alignment ?? .center
                    )
            case .adaptive:
                view
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(alignment: gridItem.alignment ?? .center)
            @unknown default:
                view
                    .frame(alignment: gridItem.alignment ?? .center)
            }
        }
    }
    
    static func alignCellForHGridItem<CellView: View>(
        view: CellView,
        gridItem: GridItem
    ) -> some View {
        build {
            switch gridItem.size {
            case .fixed(let size):
                view
                    .frame(
                        height: size,
                        alignment: gridItem.alignment ?? .center
                    )
            case .flexible(minimum: let minimum, maximum: let maximum):
                view
                    .frame(
                        minHeight: minimum,
                        maxHeight: maximum,
                        alignment: gridItem.alignment ?? .center
                    )
            case .adaptive:
                view
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(alignment: gridItem.alignment ?? .center)
            @unknown default:
                view
                    .frame(alignment: gridItem.alignment ?? .center)
            }
        }
    }
}

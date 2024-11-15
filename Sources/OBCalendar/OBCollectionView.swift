//
//  OBCollectionView.swift
//
//
//  Created by Kerim Çağlar on 24.09.2024.
//

import SwiftUI
import Foundation

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

public struct OBCollectionView<Content: View, DataType>: View {
    
    let data: [DataType]
    let isLazy: Bool
    let axis: Axis.Set
    let gridItems: [GridItem]
    let gridSpacing: CGFloat
    let scrollEnabled: Bool
    let semaphore = DispatchSemaphore(value: 1)
    
    @State private var nonLazyOrthogonalSizes: [CGFloat]
    
    @ViewBuilder
    let content: (
        _ item: DataType,
        _ index: Int,
        _ scrollProxy: ScrollViewProxy?
    ) -> Content
    
    public init(
        data: [DataType],
        isLazy: Bool = false,
        axis: Axis.Set = .vertical,
        gridItems: [GridItem] = [GridItem()],
        gridSpacing: CGFloat = 8,
        scrollEnabled: Bool = true,
        @ViewBuilder content: @escaping (
            _ item: DataType,
            _ index: Int,
            _ scrollProxy: ScrollViewProxy?
        ) -> Content
    ) {
        self.data = data
        self.isLazy = isLazy
        self.axis = axis
        self.gridItems = gridItems
        self.gridSpacing = gridSpacing
        self.scrollEnabled = scrollEnabled
        self.content = content
        
        let orthogonalGroupCount = Self.getOrthogonalGroupCount(dataCount: data.count, gridItemCount: gridItems.count)
        self.nonLazyOrthogonalSizes = Array(0..<orthogonalGroupCount)
            .map { _ in 0 }
    }
    
    public var body: some View {
        if scrollEnabled {
            ScrollViewReader { scrollProxy in
                ScrollView(axis) {
                    makeContentView(scrollProxy: scrollProxy)
                }
            }
        } else {
            makeContentView(scrollProxy: nil)
        }
    }
    
    private func makeContentView(scrollProxy: ScrollViewProxy?) -> some View {
        ContentBuilder.build {
            if isLazy {
                let contentView = makeDataContentView(scrollProxy: scrollProxy)
                if axis == .vertical {
                    LazyVGrid(columns: gridItems, spacing: gridSpacing) {
                        contentView
                    }
                } else if axis == .horizontal {
                    LazyHGrid(rows: gridItems, spacing: gridSpacing) {
                        contentView
                    }
                }
            } else {
                makeNonLazyGrid(scrollProxy: scrollProxy)
            }
        }
    }

    private func makeDataContentView(scrollProxy: ScrollViewProxy?) -> some View {
        ForEach(data.indices, id: \.self) { index in
            content(data[index], index, scrollProxy)
        }
    }
    
    private func getItemIndexFrom(groupIndex: Int, contentIndex: Int) -> Int {
        data.count * groupIndex + contentIndex
    }
    
    private static func getOrthogonalGroupCount(dataCount: Int, gridItemCount: Int) -> Int {
        let orthogonalLowerBound = dataCount / gridItemCount
        return dataCount % gridItemCount > 0
        ? orthogonalLowerBound + 1
        : orthogonalLowerBound
    }
    
    private func makeNonLazyGrid(scrollProxy: ScrollViewProxy?) -> some View {
        
        let dataCount = data.count
        let gridItemCount = gridItems.count
        let preCalculatedRowCount = dataCount / gridItemCount
        let rowCount = dataCount % gridItemCount > 0
        ? preCalculatedRowCount + 1
        : preCalculatedRowCount
        
        var contents = Array(0..<gridItemCount).map { _ in [Content]() }
        
        for index in data.indices {
            let targetIndex = index % gridItemCount
            contents[targetIndex].append(
                content(data[index], index, scrollProxy)
            )
        }
        
        return ContentBuilder.build {
            if axis == .vertical {
                VStack(spacing: gridSpacing) {
                    ForEach(0..<rowCount, id: \.self) { rowIndex in
                        HStack(spacing: .zero) {
                            ForEach(gridItems.indices, id: \.self) { columnIndex in
                                let column = contents[columnIndex]
                                let view = ContentBuilder.build {
                                    if column.isValid(index: rowIndex) {
                                        column[rowIndex]
                                    } else {
                                        Color.clear
                                    }
                                }
                                ContentBuilder.alignCellForVGridItem(
                                    view: view,
                                    gridItem: gridItems[columnIndex]
                                )
                            }
                        }
                    }
                }
            } else if axis == .horizontal {
                HStack(spacing: gridSpacing) {
                    ForEach(0..<rowCount, id: \.self) { columnIndex in
                        VStack(spacing: .zero) {
                            ForEach(gridItems.indices, id: \.self) { rowIndex in
                                let column = contents[rowIndex]
                                let view = ContentBuilder.build {
                                    if column.isValid(index: columnIndex) {
                                        column[columnIndex]
                                    } else {
                                        Color.clear
                                    }
                                }
                                ContentBuilder.alignCellForHGridItem(
                                    view: view,
                                    gridItem: gridItems[rowIndex]
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func modifyCellSizePreferenceForVGridItem<CellView: View>(
        view: CellView,
        contentIndex: Int
    ) -> some View {
        view
            .background(
                GeometryReader { geoProxy in
                    Color.clear
                        .preference(
                            key: SizePreferenceKey.self,
                            value: geoProxy.size.height
                        )
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { value in
                let current = nonLazyOrthogonalSizes[contentIndex]
                let maxVal = max(current, value)
                if maxVal != current {
                    nonLazyOrthogonalSizes[contentIndex] = maxVal
                }
            }
    }
    
    private func modifyCellSizePreferenceForHGridItem<CellView: View>(
        view: CellView,
        contentIndex: Int
    ) -> some View {
        view
            .background(
                GeometryReader { geoProxy in
                    Color.clear
                        .preference(
                            key: SizePreferenceKey.self,
                            value: geoProxy.size.width
                        )
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { value in
                let current = nonLazyOrthogonalSizes[contentIndex]
                let maxVal = max(current, value)
                if maxVal != current {
                    nonLazyOrthogonalSizes[contentIndex] = maxVal
                }
            }
    }
}

//MARK: - Preview
#Preview("Horizontal 1 - Non Lazy") {
    OBCollectionView(
        data: Array(1...10),
        isLazy: false,
        axis: .horizontal,
        gridItems: [.init(), .init(), .init()],
        gridSpacing: 8
    ) { item, index, scrollProxy in
        let text: String = index == 0
        ? "hello world"
        : "hello"
        
        Text(text)
            .background(Color.red)
            .fixedSize()
    }
    .background(Color.yellow)
}

#Preview("Horizontal 1 - Lazy") {
    OBCollectionView(
        data: Array(1...10),
        isLazy: true,
        axis: .horizontal,
        gridItems: [.init(), .init(), .init()],
        gridSpacing: 8
    ) { item, index, scrollProxy in
        let text: String = index == 0
        ? "hello world"
        : "hello"
        
        Text(text)
            .background(Color.red)
    }
    .background(Color.yellow)
}

#Preview("Vertical 1 - Non Lazy") {
    OBCollectionView(
        data: Array(1...10),
        isLazy: false,
        axis: .vertical,
        gridItems: [.init(), .init(), .init()],
        gridSpacing: 8
    ) { item, index, scrollProxy in
        let text: String = index == 0
        ? "hello world"
        : "hello"
        
        Text(text)
            .background(Color.red)
    }
    .background(Color.yellow)
}

#Preview("Vertical 1 - Lazy") {
    OBCollectionView(
        data: Array(1...10),
        isLazy: true,
        axis: .vertical,
        gridItems: [.init(), .init(), .init()],
        gridSpacing: 8
    ) { item, index, scrollProxy in
        let text: String = index == 0
        ? "hello world"
        : "hello"
        
        Text(text)
            .background(Color.red)
    }
    .background(Color.yellow)
}

#Preview("Vertical non-lazy less item") {
    OBCollectionView(
        data: Array(1...2),
        gridItems: Array(repeating: .init(), count: 3)
    ) { data, index, scrollProxy in
        Text("Lorem ipsum dolor sit amet.")
            .background(Color.red)
    }
}


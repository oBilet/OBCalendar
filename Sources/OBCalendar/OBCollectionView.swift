//
//  OBCollectionView.swift
//
//
//  Created by Kerim Çağlar on 24.09.2024.
//

import SwiftUI

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
        ContentBuilder.buildContent {
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
        
        let gridItemCount = gridItems.count
        
        var contents = Array(0..<gridItemCount).map { _ in [Content]() }
        
        for index in data.indices {
            let targetIndex = index % gridItemCount
            contents[targetIndex].append(
                content(data[index], index, scrollProxy)
            )
        }
        
        return ContentBuilder.buildContent {
            if axis == .vertical {
                HStack(alignment: .top, spacing: .zero) {
                    ForEach(gridItems.indices, id: \.self) { columnIndex in
                        
                        let gridItem = gridItems[columnIndex]
                        
                        VStack(spacing: gridSpacing) {
                            
                            if contents[columnIndex].isEmpty {
                                let spacerView = Color.clear
                                let alignedSpacer = ContentBuilder.alignCellForVGridItem(
                                    view: spacerView,
                                    gridItem: gridItem
                                )
                                modifyCellSizePreferenceForVGridItem(
                                    view: alignedSpacer,
                                    contentIndex: 0
                                )
                                .frame(
                                    height: nonLazyOrthogonalSizes.first ?? .zero
                                )
                            } else {
                                ForEach(contents[columnIndex].indices, id: \.self) { contentIndex in
                                    let cellView = contents[columnIndex][contentIndex]
                                    let alignedCellView = ContentBuilder.alignCellForVGridItem(
                                        view: cellView,
                                        gridItem: gridItem
                                    )
                                    modifyCellSizePreferenceForVGridItem(
                                        view: alignedCellView,
                                        contentIndex: contentIndex
                                    )
                                    .frame(
                                        height:  nonLazyOrthogonalSizes[contentIndex],
                                        alignment: gridItem.alignment ?? .center
                                    )
                                }
                            }
                            
                            
                        }
                    }
                }
            } else if axis == .horizontal {
                VStack(alignment: .leading, spacing: .zero) {
                    ForEach(gridItems.indices, id: \.self) { rowIndex in
                        HStack(spacing: gridSpacing) {
                            
                            let gridItem = gridItems[rowIndex]
                            
                            if contents[rowIndex].isEmpty {
                                let spacerView = Color.clear
                                let alignedSpacer = ContentBuilder.alignCellForHGridItem(
                                    view: spacerView,
                                    gridItem: gridItem
                                )
                                modifyCellSizePreferenceForHGridItem(
                                    view: alignedSpacer,
                                    contentIndex: 0
                                )
                                .frame(
                                    width: nonLazyOrthogonalSizes.first ?? .zero,
                                    alignment: gridItem.alignment ?? .center
                                )
                            } else {
                                ForEach(contents[rowIndex].indices, id: \.self) { contentIndex in
                                    let cellView = contents[rowIndex][contentIndex]
                                    let alignedCellView = ContentBuilder.alignCellForHGridItem(
                                        view: cellView,
                                        gridItem: gridItem
                                    )
                                    modifyCellSizePreferenceForHGridItem(
                                        view: alignedCellView,
                                        contentIndex: contentIndex
                                    )
                                    .frame(
                                        width: nonLazyOrthogonalSizes[contentIndex],
                                        alignment: gridItem.alignment ?? .center
                                    )
                                }
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
                nonLazyOrthogonalSizes[contentIndex] = max(current, value)
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
                nonLazyOrthogonalSizes[contentIndex] = max(current, value)
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
        let text: String = index == 1
        ? "hello world hello world hello world hello world"
        : "hello"
        
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
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
            .fixedSize(horizontal: false, vertical: true)
    }
}

// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct OBCalendar<
    Year: View,
    Month: View,
    Day: View
>: View {
    
    let years: [CalendarModel.Year]
    
    @ViewBuilder let yearContent: (
        _ year: CalendarModel.Year,
        _ scrollProxy: ScrollViewProxy?,
        _ monthsView: OBCollectionView<Month, CalendarModel.Month>
    ) -> Year
        
    @ViewBuilder let monthContent: (
        _ model: (
            year: CalendarModel.Year,
            month: CalendarModel.Month
        ),
        _ scrollProxy: (
            year: ScrollViewProxy?,
            month: ScrollViewProxy?
        ),
        _ daysView: OBCollectionView<Day, CalendarModel.Day>
    ) -> Month
    
    @ViewBuilder let dayContent: (
        _ model: (
            year: CalendarModel.Year,
            month: CalendarModel.Month,
            day: CalendarModel.Day
        ),
        _ scrollProxy: (
            year: ScrollViewProxy?,
            month: ScrollViewProxy?,
            day: ScrollViewProxy?
        )
    ) -> Day
    
    init(
        years: [CalendarModel.Year],
        
        @ViewBuilder dayContent: @escaping (
            _ model: (
                year: CalendarModel.Year,
                month: CalendarModel.Month,
                day: CalendarModel.Day
            ),
            _ scrollProxy: (
                year: ScrollViewProxy?,
                month: ScrollViewProxy?,
                day: ScrollViewProxy?
            )
        ) -> Day,
        
        @ViewBuilder monthContent: @escaping (
            _ model: (
                year: CalendarModel.Year,
                month: CalendarModel.Month
            ),
            _ scrollProxy: (
                year: ScrollViewProxy?,
                month: ScrollViewProxy?
            ),
            _ daysView: OBCollectionView<Day, CalendarModel.Day>
        ) -> Month,
        
        @ViewBuilder yearContent: @escaping (
            _ year: CalendarModel.Year,
            _ scrollProxy: ScrollViewProxy?,
            _ monthsView: OBCollectionView<Month, CalendarModel.Month>
        ) -> Year
    ) {
        self.years = years
        self.yearContent = yearContent
        self.monthContent = monthContent
        self.dayContent = dayContent
    }

    let dayGridItem: [GridItem] = [
        .init(spacing: .zero),
        .init(spacing: .zero),
        .init(spacing: .zero),
        .init(spacing: .zero),
        .init(spacing: .zero),
        .init(spacing: .zero),
        .init(spacing: .zero)
    ]
    
    public var body: some View {
        OBCollectionView(
            data: years,
            gridSpacing: .zero
        ) { year, yearIndex, yearScrollProxy in
            
        }
    }
}

#Preview {
    OBCalendar(years: []) { model, scrollProxy in
        
    } monthContent: { model, scrollProxy, dayView in
        
    } yearContent: { model, scrollProxy, monthView in
        
    }
}

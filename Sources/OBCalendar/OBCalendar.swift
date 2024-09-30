// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct OBCalendar<
    Year: View,
    Month: View,
    Day: View
>: View {
    
    let years: [CalendarModel.Year]
    let lazyYears: Bool
    let lazyMonths: Bool
    let lazyDays: Bool
    
    @ViewBuilder 
    let yearContent: (
        _ year: CalendarModel.Year,
        _ scrollProxy: ScrollViewProxy?,
        _ monthsView: OBCollectionView<Month, CalendarModel.Month>
    ) -> Year
        
    @ViewBuilder
    let monthContent: (
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
    
    @ViewBuilder 
    let dayContent: (
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
        lazyYears: Bool = false,
        lazyMonths: Bool = false,
        lazyDays: Bool = false,
        
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
        self.lazyYears = lazyYears
        self.lazyMonths = lazyMonths
        self.lazyDays = lazyDays
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
            isLazy: lazyYears,
            gridSpacing: .zero
        ) { year, yearIndex, yearScrollProxy in
            
            let monthsView = OBCollectionView(
                data: year.months,
                isLazy: lazyMonths,
                gridSpacing: .zero,
                scrollEnabled: false
            ) { month, monthIndex, monthScrollProxy in
                
                let daysView = OBCollectionView(
                    data: month.days,
                    isLazy: lazyDays,
                    gridItems: dayGridItem,
                    gridSpacing: .zero,
                    scrollEnabled: false
                ) { day,  dayIndex, dayScrollProxy in
                    self.dayContent(
                        (year, month, day),
                        (yearScrollProxy, monthScrollProxy, dayScrollProxy)
                    )
                }
                
                self.monthContent(
                    (year, month),
                    (yearScrollProxy, monthScrollProxy),
                    daysView
                )
            }
            
            self.yearContent(
                year,
                yearScrollProxy,
                monthsView
            )
        }
    }
}

#Preview {
    OBCalendar(
        years: [.init(
            year: 2024,
            months: [
                .init(
                    month: 1,
                    days: Array(1...30).map { .init(day: $0, date: Date(), type: .actual) }
                )
            ]
        )]
    ) { model, scrollProxy in
        Text("\(model.day.day)")
    } monthContent: { model, scrollProxy, dayView in
        dayView
    } yearContent: { model, scrollProxy, monthView in
        monthView
    }
}

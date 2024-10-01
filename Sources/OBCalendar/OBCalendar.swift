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
    let startingDate = Date()
    let endingDate = Calendar.current.date(byAdding: .year, value: 1, to: startingDate)!
    
    let placeholderView = Color.red
    
    return OBCalendar(
        startingDate: startingDate,
        endingDate: endingDate
    ) { model, scrollProxy in
        
        ZStack {
            if model.day.dateType == .currentMonth {
                Text("\(model.day.day)")
            } else {
                placeholderView
            }
        }
        .frame(width: 35, height: 35)
        
    } monthContent: { model, scrollProxy, dayView in
        VStack {
            Text(Calendar.current.monthSymbols[model.month.month-1])
            dayView
        }
    } yearContent: { model, scrollProxy, monthView in
        monthView
    }
}

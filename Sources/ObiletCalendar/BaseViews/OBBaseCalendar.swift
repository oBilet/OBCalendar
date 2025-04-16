// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import ObiletCollectionView

public struct OBBaseCalendar<
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

    let dayScrollEnabled: Bool
    let dayScrollAxis: Axis.Set
    let dayGridItems: [GridItem]
    let monthScrollEnabled: Bool
    let monthScrollAxis: Axis.Set
    let monthGridItems: [GridItem]
    let yearScrollEnabled: Bool
    let yearScrollAxis: Axis.Set
    let yearGridItems: [GridItem]
    
    public var body: some View {
        OBCollectionView(
            data: years,
            isLazy: lazyYears,
            axis: yearScrollAxis,
            gridItems: yearGridItems,
            gridSpacing: .zero,
            scrollEnabled: yearScrollEnabled
        ) { year, yearIndex, yearScrollProxy in
            
            let monthsView = OBCollectionView(
                data: year.months,
                isLazy: lazyMonths,
                axis: monthScrollAxis,
                gridItems: monthGridItems,
                gridSpacing: .zero,
                scrollEnabled: monthScrollEnabled
            ) { month, monthIndex, monthScrollProxy in
                
                let daysView = OBCollectionView(
                    data: month.days,
                    isLazy: lazyDays,
                    axis: dayScrollAxis,
                    gridItems: dayGridItems,
                    gridSpacing: .zero,
                    scrollEnabled: dayScrollEnabled
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
    
    var calendar = Calendar.current
    calendar.locale = .init(identifier: "en-US")
    
    return OBBaseCalendar(
        calendar: calendar,
        startDate: startingDate,
        endDate: endingDate,
        monthGridItems: [
            .init(),
            .init()
        ]
    ) { model, scrollProxy in
        
        ZStack {
            if case .insideRange(.currentMonth) = model.day.rangeType {
                Text("\(model.day.day)")
                    .font(.system(size: 3))
            } else {
                Color.clear
            }
        }
            .frame(width: 5, height: 5)
        
    } monthContent: { model, scrollProxy, dayView in
        HStack(alignment: .top) {
            Divider()
            VStack {
                Text("\(Calendar.current.monthSymbols[model.month.month-1]) \(model.year.year)")
                    .font(.system(size: 10))
                dayView
                    .padding(.vertical, 2)
            }
            Divider()
        }
    } yearContent: { model, scrollProxy, monthView in
        VStack {
            monthView
                .padding(.vertical)
            Divider()
        }
    }
}

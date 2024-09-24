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
        _ monthsView: OBCollectionView<Month,
        CalendarModel.Month>
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

    
    public var body: some View {
        Text("")
    }
}

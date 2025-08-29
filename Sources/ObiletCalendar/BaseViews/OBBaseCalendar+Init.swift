//
//  OBBaseCalendar+Init.swift
//  
//
//  Created by Metin Tarık Kiki on 1.10.2024.
//

import SwiftUI
import ObiletCollectionView

extension OBBaseCalendar {
    
    //MARK: - Years array
    public init(
        years: [CalendarModel.Year],
        lazyYears: Bool = false,
        lazyMonths: Bool = false,
        lazyDays: Bool = false,
        dayScrollEnabled: Bool = false,
        dayScrollAxis: Axis.Set = .vertical,
        dayGridItems: [GridItem] = Array(1...7).map { _ in .init() },
        monthScrollEnabled: Bool = false,
        monthScrollAxis: Axis.Set = .vertical,
        monthGridItems: [GridItem] = [GridItem()],
        yearScrollEnabled: Bool = true,
        yearScrollAxis: Axis.Set = .vertical,
        yearGridItems: [GridItem] = [GridItem()],
        
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
        self.dayScrollEnabled = dayScrollEnabled
        self.dayScrollAxis = dayScrollAxis
        self.dayGridItems = dayGridItems
        self.monthScrollEnabled = monthScrollEnabled
        self.monthScrollAxis = monthScrollAxis
        self.monthGridItems = monthGridItems
        self.yearScrollEnabled = yearScrollEnabled
        self.yearScrollAxis = yearScrollAxis
        self.yearGridItems = yearGridItems
    }
}

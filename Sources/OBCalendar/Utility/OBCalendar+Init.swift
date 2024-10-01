//
//  OBCalendar+Init.swift
//  
//
//  Created by Metin Tarık Kiki on 1.10.2024.
//

import SwiftUI

extension OBCalendar {
    
    //MARK: - Years array
    public init(
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
    
    //MARK: - Start-end date
    public init(
        startingDate: Date,
        endingDate: Date,
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
        let years = CalendarModelBuilder.defaultLayout(startingDate: startingDate, endingDate: endingDate)
        self.init(
            years: years,
            lazyYears: lazyYears,
            lazyMonths: lazyMonths,
            lazyDays: lazyDays,
            dayContent: dayContent,
            monthContent: monthContent,
            yearContent: yearContent
        )
    }
}

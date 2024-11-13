//
//  BaseCalendarView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public enum CalendarDateDrawDif {
    case day(_ value: Int)
    case month(_ value: Int)
    case year(_ value: Int)
}

public struct BaseCalendarView<
    DayContent: View,
    MonthContent: View,
    YearContent: View
>: View {
    
    let startDate: Date
    let endDate: Date
    
    let drawingRange: CalendarDateDrawDif
    let calendar: Calendar
    
    let lazyDays: Bool
    let lazyMonths: Bool
    let lazyYears: Bool
    let dayScrollEnabled: Bool
    let dayScrollAxis: Axis.Set
    let dayGridItems: [GridItem]
    let monthScrollEnabled: Bool
    let monthScrollAxis: Axis.Set
    let monthGridItems: [GridItem]
    let yearScrollEnabled: Bool
    let yearScrollAxis: Axis.Set
    let yearGridItems: [GridItem]
    
    @ViewBuilder let dayContent: (
        _ model: (
            year: CalendarModel.Year,
            month: CalendarModel.Month,
            day: CalendarModel.Day
        )
    ) -> DayContent
    
    @ViewBuilder let monthContent: (
        _ model: (
            year: CalendarModel.Year,
            month: CalendarModel.Month
        ),
        _ daysView: OBCollectionView<DayContent, CalendarModel.Day>
    ) -> MonthContent
    
    @ViewBuilder let yearContent: (
        _ model: CalendarModel.Year,
        _ monthsView: OBCollectionView<MonthContent, CalendarModel.Month>
    ) -> YearContent
    
    init(
        startDate: Date = Date(),
        drawingRange: CalendarDateDrawDif = .year(1),
        calendar: Calendar,
        lazyDays: Bool = false,
        lazyMonths: Bool = false,
        lazyYears: Bool = false,
        dayScrollEnabled: Bool = false,
        dayScrollAxis: Axis.Set = .vertical,
        dayGridItems: [GridItem] = Array(0..<7).map { _ in .init(spacing: .zero) }, // 7 day columns by default
        monthScrollEnabled: Bool = false,
        monthScrollAxis: Axis.Set = .vertical,
        monthGridItems: [GridItem] = [.init()],
        yearScrollEnabled: Bool = true,
        yearScrollAxis: Axis.Set = .vertical,
        yearGridItems: [GridItem] = [.init()],
        @ViewBuilder dayContent: @escaping (
            _ model: (
                year: CalendarModel.Year,
                month: CalendarModel.Month,
                day: CalendarModel.Day
            )
        ) -> DayContent,
        @ViewBuilder monthContent: @escaping (
            _ model: (
                year: CalendarModel.Year,
                month: CalendarModel.Month
            ),
            _ daysView: OBCollectionView<DayContent, CalendarModel.Day>
        ) -> MonthContent,
        @ViewBuilder yearContent: @escaping (
            _ model: CalendarModel.Year,
            _ monthsView: OBCollectionView<MonthContent, CalendarModel.Month>
        ) -> YearContent
    ) {
        self.drawingRange = drawingRange
        self.calendar = calendar
        
        let targetStartDate = CalendarUtility.makeStartingDate(
            using: startDate,
            calendar: calendar
        ) ?? Date()
        
        let targetEndDate = CalendarUtility.addDateDiff(
            to: targetStartDate,
            value: drawingRange,
            calendar: calendar
        )
        
        self.startDate = targetStartDate
        
        self.endDate = CalendarUtility.makeEndingDate(
            using: targetEndDate,
            calendar: calendar
        ) ?? Date()
        
        self.dayContent = dayContent
        self.monthContent = monthContent
        self.yearContent = yearContent
        
        self.lazyDays = lazyDays
        self.lazyMonths = lazyMonths
        self.lazyYears = lazyYears
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
    
    
    public var body: some View {
        calendarView
    }
    
    var calendarView: some View {
        OBBaseCalendar(
            calendar: calendar,
            startDate: startDate,
            endDate: endDate,
            lazyYears: lazyYears,
            lazyMonths: lazyMonths,
            lazyDays: lazyDays,
            dayScrollEnabled: dayScrollEnabled,
            dayScrollAxis: dayScrollAxis,
            dayGridItems: dayGridItems,
            monthScrollEnabled: monthScrollEnabled,
            monthScrollAxis: monthScrollAxis,
            monthGridItems: monthGridItems,
            yearScrollEnabled: yearScrollEnabled,
            yearScrollAxis: yearScrollAxis,
            yearGridItems: yearGridItems
        ) { model, scrollProxy in
            dayContent(model)
        } monthContent: { model, scrollProxy, daysView in
            monthContent(model, daysView)
        } yearContent: { year, scrollProxy, monthsView in
            yearContent(year, monthsView)
        }
    }
}

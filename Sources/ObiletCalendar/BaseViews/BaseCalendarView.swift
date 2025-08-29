//
//  BaseCalendarView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI
import ObiletCollectionView

private struct CalendarDrawSettings: Equatable {
    
    let startDate: Date
    let drawRange: CalendarDrawRange
}

public struct BaseCalendarView<
    DayContent: View,
    MonthContent: View,
    YearContent: View
>: View {
    
    private let drawSettings: CalendarDrawSettings
    private let calendar: Calendar
    
    private let lazyDays: Bool
    private let lazyMonths: Bool
    private let lazyYears: Bool
    private let dayScrollEnabled: Bool
    private let dayScrollAxis: Axis.Set
    private let dayGridItems: [GridItem]
    private let monthScrollEnabled: Bool
    private let monthScrollAxis: Axis.Set
    private let monthGridItems: [GridItem]
    private let yearScrollEnabled: Bool
    private let yearScrollAxis: Axis.Set
    private let yearGridItems: [GridItem]
    
    @State private var years = [CalendarModel.Year]()
    @State private var loadedOnAppearOnce = false
    
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
        drawingRange: CalendarDrawRange = .year(1),
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
        self.calendar = calendar
        
        let targetStartDate = CalendarUtility.makeStartingDate(
            using: startDate,
            calendar: calendar
        ) ?? Date()
        
        self.drawSettings = CalendarDrawSettings(
            startDate: targetStartDate,
            drawRange: drawingRange
        )
        
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
        contentView
            .onAppear {
                if !loadedOnAppearOnce {
                    loadedOnAppearOnce = true
                    generateYears(drawSettings: drawSettings)
                }
            }
            .onChange(of: drawSettings) { newValue in
                generateYears(drawSettings: newValue)
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        calendarView
    }
    
    private var calendarView: some View {
        OBBaseCalendar(
            years: years,
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
            yearGridItems: yearGridItems,
            dayContent: { model, scrollProxy in
                dayContent(model)
            },
            monthContent: { model, scrollProxy, daysView in
                monthContent(model, daysView)
            },
            yearContent: { year, scrollProxy, monthsView in
                yearContent(year, monthsView)
            },
        )
    }
    
    private func generateYears(drawSettings: CalendarDrawSettings) {
        let targetStartDate = CalendarUtility.makeStartingDate(
            using: drawSettings.startDate,
            calendar: calendar
        ) ?? Date()
        
        let targetEndDate = CalendarUtility.addDateDiff(
            to: targetStartDate,
            range: drawSettings.drawRange,
            calendar: calendar
        )
        
        let normalizedEndDate = CalendarUtility.makeEndingDate(
            using: targetEndDate,
            calendar: calendar
        ) ?? Date()
        
        self.years = CalendarModelBuilder.defaultLayout(
            calendar: calendar,
            startDate: targetStartDate,
            endDate: normalizedEndDate
        )
    }
}

private struct PreviewView: View {
    
    @State var selectedDate: Date?
    @State var startDate: Date = Date()
    @State var drawRange = CalendarDrawRange.year(400)
    
    var body: some View {
        calendarView
    }
    
    private var calendarView: some View {
        OBCalendar(
            startDate: startDate,
            drawingRange: drawRange,
            lazyYears: true,
            lazyMonths: false,
            lazyDays: false,
        )
        .dayModifier { baseView, model in
            let isSelected = selectedDate == model.day.date
            baseView
                .frame(width: 32, height: 32)
                .padding(4)
                .onTapGesture {
                    selectedDate = model.day.date
                }
                .foregroundColor(
                    isSelected
                    ? .white
                    : .primary
                )
                .background(
                    Circle()
                        .foregroundColor(
                            isSelected
                            ? .blue
                            : .clear
                        )
                )
        }
    }
}

#Preview {
    PreviewView()
}

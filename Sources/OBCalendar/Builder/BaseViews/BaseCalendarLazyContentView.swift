//
//  BaseCalendarView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public struct BaseCalendarLazyContentView<
    DayContent: View,
    MonthContent: View,
    YearContent: View,
    ScrollIdType: Hashable
>: View {
    
    let startDate: Date
    let endDate: Date
    
    let yearLimit: Int
    let calendar: Calendar
    
    let lazyYears: Bool
    let lazyMonths: Bool
    let dayScrollEnabled: Bool
    let dayScrollAxis: Axis.Set
    let dayGridItems: [GridItem]
    let monthScrollEnabled: Bool
    let monthScrollAxis: Axis.Set
    let monthGridItems: [GridItem]
    let yearScrollEnabled: Bool
    let yearScrollAxis: Axis.Set
    let yearGridItems: [GridItem]
    
    @Binding var scrollTrigger: ScrollIdType?
    @State private var appearedOnce = false
    @State private var lazyDays = true
    
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
        yearLimit: Int = 2,
        calendar: Calendar,
        scrollTrigger: Binding<ScrollIdType?>,
        lazyYears: Bool = false,
        lazyMonths: Bool = false,
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
        self.yearLimit = yearLimit
        self.calendar = calendar
        self._scrollTrigger = scrollTrigger
        
        let targetStartDate = CalendarUtility.makeStartingDate(
            using: startDate,
            calendar: calendar
        ) ?? Date()
        
        let targetEndDate = CalendarUtility.addYear(
            to: targetStartDate,
            value: yearLimit,
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
        
        self.lazyYears = lazyYears
        self.lazyMonths = lazyMonths
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
        VStack(spacing: 0) {
            contentView
        }
    }
    
    var contentView: some View {
        ScrollViewReader { scrollProxy in
            ContentBuilder.build {
                if appearedOnce {
                    calendarView
                        .onAppear {
                            if lazyDays {
                                Task {
                                    try? await Task.sleep(seconds: 0.2)
                                    await MainActor.run {
                                        lazyDays = false
                                    }
                                }
                            }
                        }
                } else {
                    Spacer()
                        .overlay(
                            ProgressView()
                        )
                }
            }
            .onChange(of: scrollTrigger) { newValue in
                scrollTo(scrollProxy: scrollProxy)
            }
            .onChange(of: lazyDays) { newValue in
                performScrollRequest(
                    scrollProxy: scrollProxy,
                    animated: false
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.linear(duration: 0.1)) {
                    appearedOnce = true
                }
            }
        }
    }
    
    var calendarView: some View {
        OBCalendar(
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
    
    private func scrollTo(
        scrollProxy: ScrollViewProxy,
        animated: Bool = false
    ) {
        if appearedOnce {
            performScrollRequest(
                scrollProxy: scrollProxy,
                animated: animated
            )
        }
    }
    
    private func performScrollRequest(
        scrollProxy: ScrollViewProxy,
        animated: Bool = true
    ) {
        guard let scrollTrigger
        else { return }
        if animated {
            withAnimation {
                scrollProxy.scrollTo(scrollTrigger, anchor: .top)
            }
        } else {
            scrollProxy.scrollTo(scrollTrigger, anchor: .top)
        }
    }
}

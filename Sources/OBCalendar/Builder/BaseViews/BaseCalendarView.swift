//
//  BaseCalendarView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

private extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}


private extension Array {
    func shifted(by offset: Int) -> Self {
        let offsetMod = offset % self.count
        return Array(self[offsetMod..<self.count] + self[0..<offsetMod])
    }
}

private class Utility {
    static func makeStartingDate(
        using date: Date?,
        calendar: Calendar
    ) -> Date? {
        let date = date ?? Date()
        
        let targetComponents = calendar.dateComponents([.year, .month], from: date)
        
        let resultComponents = DateComponents(
            year: targetComponents.year,
            month: targetComponents.month,
            day: 1
        )
        
        return calendar.date(from: resultComponents)
    }
    
    static func makeEndingDate(
        using date: Date?,
        calendar: Calendar
    ) -> Date? {
        guard let date,
              let monthUpperBound = calendar.range(
                of: .day,
                in: .month,
                for: date
              )?.upperBound
        else { return nil }
        
        let targetComponents = calendar.dateComponents(
            [.year, .month],
            from: date
        )
        
        let resultComponents = DateComponents(
            year: targetComponents.year,
            month: targetComponents.month,
            day: monthUpperBound - 1
        )
        
        return calendar.date(from: resultComponents)
    }
    
    static func addYear(
        to date: Date,
        value: Int = 1,
        calendar: Calendar
    ) -> Date? {
        calendar.date(byAdding: .year, value: value, to: date)
    }
}

public struct CalendarView<
    DayContent: View,
    MonthContent: View,
    YearContent: View,
    ScrollIdType: Hashable
>: View {
    
    let startDate: Date
    let endDate: Date
    
    let yearLimit: Int
    let calendar: Calendar
    
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
        
        let targetStartDate = Utility.makeStartingDate(
            using: startDate,
            calendar: calendar
        ) ?? Date()
        
        let targetEndDate = Utility.addYear(
            to: targetStartDate,
            value: yearLimit,
            calendar: calendar
        )
        
        self.startDate = targetStartDate
        
        self.endDate = Utility.makeEndingDate(
            using: targetEndDate,
            calendar: calendar
        ) ?? Date()
        
        self.dayContent = dayContent
        self.monthContent = monthContent
        self.yearContent = yearContent
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
            startDate: startDate,
            endDate: endDate,
            lazyDays: lazyDays
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

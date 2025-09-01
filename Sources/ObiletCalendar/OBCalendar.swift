//
//  CalendarBuilder.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import Foundation
import SwiftUI
import ObiletCollectionView

public struct OBCalendar<
    DayContent: View,
    MonthContent: View,
    YearContent: View
> {
    
    public typealias ModifiedDayMonthType<ModifiedDayContent: View> = BaseCalendarMonthView<OBCollectionView<_ConditionalContent<ModifiedDayContent, _ConditionalContent<ModifiedDayContent, Color>>, CalendarModel.Day>>
    
    public typealias ModifiedDayYearType<ModifiedDayContent: View> = BaseCalendarYearView<OBCollectionView<BaseCalendarMonthView<OBCollectionView<_ConditionalContent<ModifiedDayContent, _ConditionalContent<ModifiedDayContent, Color>>, CalendarModel.Day>>, CalendarModel.Month>>
    
    public typealias ModifiedMonthYearType<ModifiedMonthContent: View> = BaseCalendarYearView<OBCollectionView<ModifiedMonthContent, CalendarModel.Month>>
    
    public typealias ModifiedDayBuilder<ModifiedDayContent: View> = OBCalendar<
        ModifiedDayContent,
        ModifiedDayMonthType<ModifiedDayContent>,
        ModifiedDayYearType<ModifiedDayContent>
    >
    
    public typealias ModifiedMonthBuilder<ModifiedMonthContent: View> = OBCalendar<
        DayContent,
        ModifiedMonthContent,
        ModifiedMonthYearType<ModifiedMonthContent>
    >
    
    public typealias ModifiedYearBuilder<ModifiedYearContent: View> = OBCalendar<DayContent, MonthContent, ModifiedYearContent>
    
    public typealias DayModel = CalendarModel.DayViewModel//(year: CalendarModel.Year, month: CalendarModel.Month, day: CalendarModel.Day)
    public typealias MonthModel = CalendarModel.MonthViewModel//(year: CalendarModel.Year, month: CalendarModel.Month)
    public typealias YearModel = CalendarModel.YearViewModel//CalendarModel.Year
    
    public typealias BaseDayView = BaseCalendarDayView
    public typealias BaseMonthView = BaseCalendarMonthView<OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>>
    public typealias BaseYearView = BaseCalendarYearView<OBCollectionView<MonthContent, CalendarModel.Month>>
    
    @ViewBuilder private var dayContent: (
        _ baseView: BaseCalendarDayView,
        _ viewModel: DayModel
    ) -> DayContent
    
    @ViewBuilder private var monthContent: (
        _ baseView: BaseMonthView,
        _ daysView: OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>,
        _ viewModel: MonthModel
    ) -> MonthContent
    
    @ViewBuilder private var yearContent: (
        _ baseView: BaseYearView,
        _ monthsView: OBCollectionView<MonthContent, CalendarModel.Month>,
        _ viewModel: YearModel
    ) -> YearContent
    
    var startDate: Date
    var drawingRange: CalendarDrawRange
    var calendar: Calendar
    var includeBlanks: Bool
    
    let lazyYears: Bool
    let lazyMonths: Bool
    let lazyDays: Bool
    let dayScrollEnabled: Bool
    let dayScrollAxis: Axis.Set
    let dayGridItems: [GridItem]
    let monthScrollEnabled: Bool
    let monthScrollAxis: Axis.Set
    let monthGridItems: [GridItem]
    let yearScrollEnabled: Bool
    let yearScrollAxis: Axis.Set
    let yearGridItems: [GridItem]
    
    internal init(
        startDate: Date,
        drawingRange: CalendarDrawRange,
        calendar: Calendar,
        includeBlanks: Bool = false,
        lazyYears: Bool = false,
        lazyMonths: Bool = false,
        lazyDays: Bool = false,
        dayScrollEnabled: Bool = false,
        dayScrollAxis: Axis.Set = .vertical,
        dayGridItems: [GridItem] = Array(0..<7).map { _ in .init() }, // 7 day columns by default
        monthScrollEnabled: Bool = false,
        monthScrollAxis: Axis.Set = .vertical,
        monthGridItems: [GridItem] = [.init()],
        yearScrollEnabled: Bool = true,
        yearScrollAxis: Axis.Set = .vertical,
        yearGridItems: [GridItem] = [.init()],
        
        @ViewBuilder dayContent: @escaping (
            _ baseView: BaseDayView,
            _ viewModel: DayModel
        ) -> DayContent,
        
        @ViewBuilder monthContent: @escaping (
            _ baseView: BaseMonthView,
            _ daysView: OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>,
            _ viewModel: MonthModel
        ) -> MonthContent,
        
        @ViewBuilder yearContent: @escaping (
            _ baseView: BaseYearView,
            _ monthsView: OBCollectionView<MonthContent, CalendarModel.Month>,
            _ viewModel: YearModel
        ) -> YearContent
    ) {
        self.dayContent = dayContent
        self.monthContent = monthContent
        self.yearContent = yearContent
        self.startDate = startDate
        self.drawingRange = drawingRange
        self.calendar = calendar
        self.includeBlanks = includeBlanks
        self.lazyYears = lazyYears
        self.lazyMonths = lazyMonths
        self.lazyDays = lazyDays
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
    
    ///This modifier should be called before monthModifier.
    public func dayModifier<ModifiedDayContent: View>(
        @ViewBuilder _ modifier: @escaping (
            _ baseView: BaseDayView,
            _ viewModel: DayModel
        ) -> ModifiedDayContent
    ) -> ModifiedDayBuilder<_ConditionalContent<ModifiedDayContent, _ConditionalContent<ModifiedDayContent, Color>>> {
        
        .init(
            startDate: startDate,
            drawingRange: drawingRange,
            calendar: calendar,
            includeBlanks: includeBlanks,
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
        ) { baseView, viewModel in
            
            if includeBlanks {
                modifier(baseView, viewModel)
            } else {
                if case .insideRange(.currentMonth) = viewModel.day.rangeType {
                    modifier(baseView, viewModel)
                } else {
                    Color.clear
                }
            }
            
        } monthContent: { baseView, daysView, viewModel in
            baseView
        } yearContent: { baseView, monthsView, viewModel in
            baseView
        }
    }
    
    ///This modifier should be called before yearModifier and after dayModifier.
    public func monthModifier<ModifiedMonthContent: View>(
        @ViewBuilder _ modifier: @escaping (
            _ baseView: BaseMonthView,
            _ daysView: OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>,
            _ viewModel: MonthModel
        ) -> ModifiedMonthContent
    ) -> ModifiedMonthBuilder<ModifiedMonthContent> {
        
        .init(
            startDate: startDate,
            drawingRange: drawingRange,
            calendar: calendar,
            includeBlanks: includeBlanks,
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
            dayContent: dayContent
        ) { baseView, daysView, viewModel in
            modifier(baseView, daysView, viewModel)
        } yearContent: { baseView, monthsView, viewModel in
            baseView
        }
    }
    
    ///This modifier should be called after monthModifier.
    public func yearModifier<ModifiedYearContent: View>(
        @ViewBuilder _ modifier: @escaping (
            _ baseView: BaseYearView,
            _ monthsView: OBCollectionView<MonthContent, CalendarModel.Month>,
            _ viewModel: YearModel
        ) -> ModifiedYearContent
    ) -> ModifiedYearBuilder<ModifiedYearContent> {
        
        .init(
            startDate: startDate,
            drawingRange: drawingRange,
            calendar: calendar,
            includeBlanks: includeBlanks,
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
            dayContent: dayContent,
            monthContent: monthContent
        ) { baseView, monthsView, viewModel in
            modifier(baseView, monthsView, viewModel)
        }
    }
}

extension OBCalendar: View {
    
    public var body: some View {
        BaseCalendarView(
            startDate: startDate,
            drawingRange: drawingRange,
            calendar: calendar,
            lazyDays: lazyDays,
            lazyMonths: lazyMonths,
            lazyYears: lazyYears,
            dayScrollEnabled: dayScrollEnabled,
            dayScrollAxis: dayScrollAxis,
            dayGridItems: dayGridItems,
            monthScrollEnabled: monthScrollEnabled,
            monthScrollAxis: monthScrollAxis,
            monthGridItems: monthGridItems,
            yearScrollEnabled: yearScrollEnabled,
            yearScrollAxis: yearScrollAxis,
            yearGridItems: yearGridItems
        ) { viewModel in
            let view = BaseCalendarDayView(viewModel: viewModel)
            if includeBlanks {
                dayContent(view, viewModel)
            } else {
                if case .insideRange(.currentMonth) = viewModel.day.rangeType {
                    dayContent(view, viewModel)
                } else {
                    Color.clear
                }
            }
            
        } monthContent: { viewModel, daysView in
            let view = BaseCalendarMonthView(
                viewModel: viewModel,
                daysView: daysView,
                calendar: calendar
            )
            
            monthContent(view, daysView, viewModel)
            
        } yearContent: { viewModel, monthsView in
            let view = BaseCalendarYearView(viewModel: viewModel, monthsView: monthsView)
            yearContent(view, monthsView, viewModel)
        }
    }
}

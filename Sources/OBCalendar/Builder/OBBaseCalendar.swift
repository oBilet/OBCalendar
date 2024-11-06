//
//  CalendarBuilder.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import Foundation
import SwiftUI

public struct OBBaseCalendar<
    DayContent: View,
    MonthContent: View,
    YearContent: View
> {
    
    public typealias ModifiedDayMonthType<ModifiedDayContent: View> = BaseCalendarMonthView<OBCollectionView<_ConditionalContent<ModifiedDayContent, _ConditionalContent<ModifiedDayContent, Color>>, CalendarModel.Day>>
    
    public typealias ModifiedDayYearType<ModifiedDayContent: View> = BaseCalendarYearView<OBCollectionView<BaseCalendarMonthView<OBCollectionView<_ConditionalContent<ModifiedDayContent, _ConditionalContent<ModifiedDayContent, Color>>, CalendarModel.Day>>, CalendarModel.Month>>
    
    public typealias ModifiedMonthYearType<ModifiedMonthContent: View> = BaseCalendarYearView<OBCollectionView<ModifiedMonthContent, CalendarModel.Month>>
    
    public typealias ModifiedDayBuilder<ModifiedDayContent: View> = OBBaseCalendar<
        ModifiedDayContent,
        ModifiedDayMonthType<ModifiedDayContent>,
        ModifiedDayYearType<ModifiedDayContent>
    >
    
    public typealias ModifiedMonthBuilder<ModifiedMonthContent: View> = OBBaseCalendar<
        DayContent,
        ModifiedMonthContent,
        ModifiedMonthYearType<ModifiedMonthContent>
    >
    
    public typealias ModifiedYearBuilder<ModifiedYearContent: View> = OBBaseCalendar<DayContent, MonthContent, ModifiedYearContent>
    
    public typealias DayModel = (year: CalendarModel.Year, month: CalendarModel.Month, day: CalendarModel.Day)
    public typealias MonthModel = (year: CalendarModel.Year, month: CalendarModel.Month)
    public typealias YearModel = CalendarModel.Year
    
    public typealias BaseDayView = BaseCalendarDayView
    public typealias BaseMonthView = BaseCalendarMonthView<OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>>
    public typealias BaseYearView = BaseCalendarYearView<OBCollectionView<MonthContent, CalendarModel.Month>>
    
    @ViewBuilder private var dayContent: (
        _ baseView: BaseCalendarDayView,
        _ model: DayModel
    ) -> DayContent
    
    @ViewBuilder private var monthContent: (
        _ baseView: BaseMonthView,
        _ daysView: OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>,
        _ model: MonthModel
    ) -> MonthContent
    
    @ViewBuilder private var yearContent: (
        _ baseView: BaseYearView,
        _ monthsView: OBCollectionView<MonthContent, CalendarModel.Month>,
        _ model: YearModel
    ) -> YearContent
    
    var startDate: Date
    var yearLimit: Int
    var calendar: Calendar
    var includeBlanks: Bool
    
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
    
    internal init(
        startDate: Date,
        yearLimit: Int,
        calendar: Calendar,
        includeBlanks: Bool = false,
        lazyYears: Bool = false,
        lazyMonths: Bool = false,
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
            _ model: DayModel
        ) -> DayContent,
        
        @ViewBuilder monthContent: @escaping (
            _ baseView: BaseMonthView,
            _ daysView: OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>,
            _ model: MonthModel
        ) -> MonthContent,
        
        @ViewBuilder yearContent: @escaping (
            _ baseView: BaseYearView,
            _ monthsView: OBCollectionView<MonthContent, CalendarModel.Month>,
            _ model: YearModel
        ) -> YearContent
    ) {
        self.dayContent = dayContent
        self.monthContent = monthContent
        self.yearContent = yearContent
        self.startDate = startDate
        self.yearLimit = yearLimit
        self.calendar = calendar
        self.includeBlanks = includeBlanks
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
    
    ///This modifier should be called before monthModifier.
    public func dayModifier<ModifiedDayContent: View>(
        @ViewBuilder _ modifier: @escaping (
            _ baseView: BaseDayView,
            _ model: DayModel
        ) -> ModifiedDayContent
    ) -> ModifiedDayBuilder<_ConditionalContent<ModifiedDayContent, _ConditionalContent<ModifiedDayContent, Color>>> {
        
        .init(
            startDate: startDate,
            yearLimit: yearLimit,
            calendar: calendar,
            includeBlanks: includeBlanks,
            lazyYears: lazyYears,
            lazyMonths: lazyMonths,
            dayScrollEnabled: dayScrollEnabled,
            dayScrollAxis: dayScrollAxis,
            dayGridItems: dayGridItems,
            monthScrollEnabled: monthScrollEnabled,
            monthScrollAxis: monthScrollAxis,
            monthGridItems: monthGridItems,
            yearScrollEnabled: yearScrollEnabled,
            yearScrollAxis: yearScrollAxis,
            yearGridItems: yearGridItems
        ) { baseView, model in
            
            if includeBlanks {
                modifier(baseView, model)
            } else {
                if case .insideRange(.currentMonth) = model.day.rangeType {
                    modifier(baseView, model)
                } else {
                    Color.clear
                }
            }
            
        } monthContent: { baseView, daysView, model in
            baseView
        } yearContent: { baseView, monthsView, model in
            baseView
        }
    }
    
    ///This modifier should be called before yearModifier and after dayModifier.
    public func monthModifier<ModifiedMonthContent: View>(
        @ViewBuilder _ modifier: @escaping (
            _ baseView: BaseMonthView,
            _ daysView: OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>,
            _ model: MonthModel
        ) -> ModifiedMonthContent
    ) -> ModifiedMonthBuilder<ModifiedMonthContent> {
        
        .init(
            startDate: startDate,
            yearLimit: yearLimit,
            calendar: calendar,
            includeBlanks: includeBlanks,
            lazyYears: lazyYears,
            lazyMonths: lazyMonths,
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
        ) { baseView, daysView, model in
            modifier(baseView, daysView, model)
        } yearContent: { baseView, monthsView, model in
            baseView
        }
    }
    
    ///This modifier should be called after monthModifier.
    public func yearModifier<ModifiedYearContent: View>(
        @ViewBuilder _ modifier: @escaping (
            _ baseView: BaseYearView,
            _ monthsView: OBCollectionView<MonthContent, CalendarModel.Month>,
            _ model: YearModel
        ) -> ModifiedYearContent
    ) -> ModifiedYearBuilder<ModifiedYearContent> {
        
        .init(
            startDate: startDate,
            yearLimit: yearLimit,
            calendar: calendar,
            includeBlanks: includeBlanks,
            lazyYears: lazyYears,
            lazyMonths: lazyMonths,
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
        ) { baseView, monthsView, model in
            modifier(baseView, monthsView, model)
        }
    }
}

extension OBBaseCalendar: View {
    
    public var body: some View {
        BaseCalendarView(
            startDate: startDate,
            yearLimit: yearLimit,
            calendar: calendar,
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
        ) { model in
            let view = BaseCalendarDayView(model: model, calendar: calendar)
            if includeBlanks {
                dayContent(view, model)
            } else {
                if case .insideRange(.currentMonth) = model.day.rangeType {
                    dayContent(view, model)
                } else {
                    Color.clear
                }
            }
            
        } monthContent: { model, daysView in
            let view = BaseCalendarMonthView(
                model: model,
                daysView: daysView,
                calendar: calendar
            )
            
            monthContent(view, daysView, model)
            
        } yearContent: { model, monthsView in
            let view = BaseCalendarYearView(model: model, monthsView: monthsView)
            yearContent(view, monthsView, model)
        }
    }
}

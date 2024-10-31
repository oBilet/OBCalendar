//
//  CalendarBuilder.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import Foundation
import SwiftUI

public struct CalendarBuilder<
    DayContent: View,
    MonthContent: View,
    YearContent: View,
    ScrollIdType: Hashable
> {
    
    public typealias BuiltContent = BaseCalendarView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, MonthContent, YearContent, ScrollIdType>
    
    public typealias ModifiedDayMonthType<ModifiedDayContent: View> = BaseCalendarMonthView<OBCollectionView<_ConditionalContent<ModifiedDayContent, _ConditionalContent<ModifiedDayContent, Color>>, CalendarModel.Day>>
    
    public typealias ModifiedDayYearType<ModifiedDayContent: View> = BaseCalendarYearView<OBCollectionView<BaseCalendarMonthView<OBCollectionView<_ConditionalContent<ModifiedDayContent, _ConditionalContent<ModifiedDayContent, Color>>, CalendarModel.Day>>, CalendarModel.Month>>
    
    public typealias ModifiedMonthYearType<ModifiedMonthContent: View> = BaseCalendarYearView<OBCollectionView<ModifiedMonthContent, CalendarModel.Month>>
    
    public typealias ModifiedDayBuilder<ModifiedDayContent: View> = CalendarBuilder<
        ModifiedDayContent,
        ModifiedDayMonthType<ModifiedDayContent>,
        ModifiedDayYearType<ModifiedDayContent>,
        ScrollIdType
    >
    
    public typealias ModifiedMonthBuilder<ModifiedMonthContent: View> = CalendarBuilder<
        DayContent,
        ModifiedMonthContent,
        ModifiedMonthYearType<ModifiedMonthContent>,
        ScrollIdType
    >
    
    public typealias ModifiedYearBuilder<ModifiedYearContent: View> = CalendarBuilder<DayContent, MonthContent, ModifiedYearContent, ScrollIdType>
    
    public typealias DayModel = (year: CalendarModel.Year, month: CalendarModel.Month, day: CalendarModel.Day)
    public typealias MonthModel = (year: CalendarModel.Year, month: CalendarModel.Month)
    public typealias YearModel = CalendarModel.Year
    
    public typealias BaseDayView = BaseCalendarDayView<Color>
    public typealias BaseMonthView = BaseCalendarMonthView<OBCollectionView<_ConditionalContent<DayContent, _ConditionalContent<DayContent, Color>>, CalendarModel.Day>>
    public typealias BaseYearView = BaseCalendarYearView<OBCollectionView<MonthContent, CalendarModel.Month>>
    
    @ViewBuilder private var dayContent: (
        _ baseView: BaseCalendarDayView<Color>,
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
    var scrollTrigger: Binding<ScrollIdType?>
    var includeBlanks: Bool
    
    internal init(
        startDate: Date,
        yearLimit: Int,
        calendar: Calendar,
        scrollTrigger: Binding<ScrollIdType?>,
        includeBlanks: Bool = false,
        
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
        self.scrollTrigger = scrollTrigger
        self.includeBlanks = includeBlanks
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
            scrollTrigger: scrollTrigger,
            includeBlanks: includeBlanks
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
            scrollTrigger: scrollTrigger,
            includeBlanks: includeBlanks,
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
            scrollTrigger: scrollTrigger,
            includeBlanks: includeBlanks,
            dayContent: dayContent,
            monthContent: monthContent
        ) { baseView, monthsView, model in
            modifier(baseView, monthsView, model)
        }
    }
    
    public func build() -> BuiltContent {
        
        return BaseCalendarView(
            startDate: startDate,
            yearLimit: yearLimit,
            calendar: .current,
            scrollTrigger: scrollTrigger
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
            //TODO: Change the specialDays array type for it to be comparable with dates
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

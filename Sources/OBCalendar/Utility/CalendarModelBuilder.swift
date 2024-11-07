//
//  CalendarModelBuilder.swift
//
//
//  Created by Metin Tarık Kiki on 30.09.2024.
//

import Foundation

public enum CalendarModelBuilder {

    //MARK: - Default Layout
    public static func defaultLayout(
        calendar: Calendar = .current,
        startDate: Date,
        endDate: Date
    ) -> [CalendarModel.Year] {
        
        var result = [CalendarModel.Year]()
        result.appendYear(number: calendar.component(.year, from: startDate))
        result.appendMonth(number: calendar.component(.month, from: startDate))
        
        var currentDate = startDate
        
        let weekdayCount = calendar.weekdaySymbols.count
        
        while currentDate <= endDate {
            
            let isYearChanged = calendar.component(.year, from: currentDate) != result[result.endIndex-1].year
            
            let currentYear = calendar.component(.year, from: currentDate)
            let currentMonth = calendar.component(.month, from: currentDate)
            let currentDay = calendar.component(.day, from: currentDate)
            
            if isYearChanged {
                result.appendYear(number: currentYear)
                result.appendMonth(number: currentMonth)
            } else {
                let isMonthChanged = result[result.endIndex-1].months.last?.month != currentMonth
                
                if isMonthChanged {
                    result.appendMonth(number: currentMonth)
                }
            }
            
            if currentDay == 1 || currentDate == startDate {
                addBeginningPlaceholder(
                    calendar: calendar,
                    totalWeekdayCount: weekdayCount,
                    targetDate: currentDate,
                    startingDate: startDate,
                    result: &result
                )
            }
            
            result.appendDay(
                number: currentDay,
                date: currentDate,
                dateType: .insideRange(.currentMonth)
            )
            
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                
                let isLastDayOfMonth = nextDay.isFirstDayOfMonth(calendar: calendar)
                
                if isLastDayOfMonth || currentDate == endDate {
                    addEndingPlaceholder(
                        calendar: calendar,
                        totalWeekdayCount: weekdayCount,
                        targetDate: currentDate,
                        endingDate: endDate,
                        result: &result
                    )
                }
                
                currentDate = nextDay
            } else {
                break
            }
        }
        
        return result
    }
}

//MARK: - Private helpers
private extension CalendarModelBuilder {
    
    static func getBeginningPlaceholderCount(calendar: Calendar, totalWeekdayCount: Int, targetDate: Date) -> Int {
        let currentWeekday = calendar.component(.weekday, from: targetDate)
        let firstWeekday = calendar.firstWeekday
        return (currentWeekday - firstWeekday + totalWeekdayCount) % totalWeekdayCount
    }
    
    static func getEndingPlaceholderCount(calendar: Calendar, totalWeekdayCount: Int, targetDate: Date) -> Int {
        let targetWeekday = calendar.component(.weekday, from: targetDate)
        let firstWeekday = calendar.firstWeekday
        return (totalWeekdayCount - targetWeekday + firstWeekday - 1) % totalWeekdayCount
    }
    
    static func addBeginningPlaceholder(
        calendar: Calendar,
        totalWeekdayCount: Int,
        targetDate: Date,
        startingDate: Date,
        result: inout [CalendarModel.Year]
    ) {
        let placeholderCount = getBeginningPlaceholderCount(
            calendar: calendar,
            totalWeekdayCount: totalWeekdayCount,
            targetDate: targetDate
        )
        
        if placeholderCount > .zero {
            for index in stride(from: placeholderCount, to: 0, by: -1) {
                let dateToBeAdded = calendar.date(byAdding: .day, value: -index, to: targetDate) ?? Date()
                result.appendDay(
                    number: calendar.component(.day, from: dateToBeAdded),
                    date: dateToBeAdded,
                    dateType: dateToBeAdded < startingDate
                    ? .outOfRange(
                        calendar.compare(dateToBeAdded, to: startingDate, toGranularity: .month) == .orderedSame
                        ? .currentMonth
                        : .previousMonth
                    )
                    : .insideRange(.previousMonth)
                )
            }
        }
    }
    
    static func addEndingPlaceholder(
        calendar: Calendar,
        totalWeekdayCount: Int,
        targetDate: Date,
        endingDate: Date,
        result: inout [CalendarModel.Year]
    ) {
        let placeholderCount = getEndingPlaceholderCount(
            calendar: calendar,
            totalWeekdayCount: totalWeekdayCount,
            targetDate: targetDate
        )
        
        if placeholderCount > .zero {
            for index in 1...placeholderCount {
                let nextDate = calendar.date(byAdding: .day, value: index, to: targetDate)
                let number = if let date = nextDate {
                    calendar.component(.day, from: date)
                } else {
                    index
                }
                let dateToBeAdded = nextDate ?? Date()
                result.appendDay(
                    number: number,
                    date: dateToBeAdded,
                    dateType: dateToBeAdded > endingDate
                    ? .outOfRange(
                        calendar.compare(dateToBeAdded, to: endingDate, toGranularity: .month) == .orderedSame
                        ? .currentMonth
                        : .nextMonth
                    )
                    : .insideRange(.nextMonth)
                )
            }
        }
    }
}

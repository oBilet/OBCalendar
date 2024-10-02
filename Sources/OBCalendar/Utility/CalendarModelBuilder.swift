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
        startingDate: Date,
        endingDate: Date
    ) -> [CalendarModel.Year] {
        
        var result = [CalendarModel.Year]()
        result.appendYear(number: calendar.component(.year, from: startingDate))
        result.appendMonth(number: calendar.component(.month, from: startingDate))
        
        var currentDate = startingDate
        
        let weekdayCount = calendar.weekdaySymbols.count
        
        while currentDate <= endingDate {
            
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
            
            if currentDay == 1 || currentDate == startingDate {
                addBeginningPlaceholder(
                    calendar: calendar,
                    totalWeekdayCount: weekdayCount,
                    targetDate: currentDate,
                    result: &result
                )
            }
            
            result.appendDay(
                number: currentDay,
                date: currentDate,
                dateType: .currentMonth
            )
            
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                
                let isLastDayOfMonth = nextDay.isFirstDayOfMonth(calendar: calendar)
                
                if isLastDayOfMonth {
                    addEndingPlaceholder(
                        calendar: calendar,
                        totalWeekdayCount: weekdayCount,
                        targetDate: currentDate,
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
extension CalendarModelBuilder {
    
    private static func getBeginningPlaceholderCount(calendar: Calendar, totalWeekdayCount: Int, targetDate: Date) -> Int {
        let currentWeekday = calendar.component(.weekday, from: targetDate)
        let firstWeekday = calendar.firstWeekday
        return (currentWeekday - firstWeekday + totalWeekdayCount) % totalWeekdayCount
    }
    
    private static func getEndingPlaceholderCount(calendar: Calendar, totalWeekdayCount: Int, targetDate: Date) -> Int {
        let targetWeekday = calendar.component(.weekday, from: targetDate)
        let firstWeekday = calendar.firstWeekday
        return (totalWeekdayCount - targetWeekday + firstWeekday - 1) % totalWeekdayCount
    }
    
    private static func addBeginningPlaceholder(
        calendar: Calendar,
        totalWeekdayCount: Int,
        targetDate: Date,
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
                    dateType: .previousMonth
                )
            }
        }
    }
    
    private static func addEndingPlaceholder(
        calendar: Calendar,
        totalWeekdayCount: Int,
        targetDate: Date,
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
                result.appendDay(
                    number: number,
                    date: nextDate ?? Date(),
                    dateType: .nextMonth
                )
            }
        }
    }
}

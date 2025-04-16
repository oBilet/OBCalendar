//
//  CalendarUtility.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import Foundation

enum CalendarUtility {
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
    
    static func addDateDiff(
        to date: Date,
        range: CalendarDrawRange,
        calendar: Calendar
    ) -> Date? {
        let target = range.calendarTarget
        return calendar.date(
            byAdding: target.component,
            value: target.value,
            to: date
        )
    }
}

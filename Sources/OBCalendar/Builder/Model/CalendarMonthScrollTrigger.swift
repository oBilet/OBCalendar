//
//  CalendarMonthScrollTrigger.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import Foundation

public struct CalendarMonthScrollTrigger: Hashable {
    
    public var date: Date?
    public var calendar: Calendar
    
    var id: String? {
        guard let date
        else { return nil }
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return "\(month)\(year)"
    }
    
    public init?(calendar: Calendar) {
        self.calendar = calendar
    }
    
    public init(
        date: Date?,
        calendar: Calendar
    ) {
        self.date = date
        self.calendar = calendar
    }
    
    public init(
        month: CalendarModel.Month,
        year: CalendarModel.Year,
        calendar: Calendar
    ) {
        let dc = DateComponents(year: year.year, month: month.month, day: 1)
        self.date = calendar.date(from: dc)!
        self.calendar = calendar
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public static func == (lhs: CalendarMonthScrollTrigger, rhs: CalendarMonthScrollTrigger) -> Bool {
        return lhs.id == rhs.id
    }
}

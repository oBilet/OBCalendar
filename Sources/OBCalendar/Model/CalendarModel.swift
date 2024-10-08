//
//  CalendarModel.swift
//
//
//  Created by Kerim Çağlar on 24.09.2024.
//

import Foundation

public enum CalendarModel {
    
    public struct Year {
        public let year: Int
        public var months: [Month]
    }
    
    public struct Month {
        public let month: Int
        public var days: [Day]
    }
    
    public struct Day {
        
        public enum DateType {
            case previousMonth
            case nextMonth
            case currentMonth
        }
        
        public enum RangeType {
            case outOfRange(DateType)
            case insideRange(DateType)
        }
        
        public let day: Int
        public let date: Date
        public let rangeType: RangeType
    }
}

extension Array where Element == CalendarModel.Year {
    mutating func appendDay(number: Int, date: Date, dateType: CalendarModel.Day.RangeType) {
        let lastMonths = self[self.endIndex-1].months
        self[self.endIndex-1]
            .months[lastMonths.endIndex-1]
            .days
            .append(
                .init(
                    day: number,
                    date: date,
                    rangeType: dateType
                )
            )
    }
    
    mutating func appendYear(number: Int) {
        self.append(
            .init(
                year: number,
                months: []
            )
        )
    }
    
    mutating func appendMonth(number: Int) {
        self[self.endIndex-1]
            .months
            .append(
                .init(
                    month: number,
                    days: []
                )
            )
    }
}

extension Array where Element == CalendarModel.Month {
    var lastMonth: CalendarModel.Month {
        self[endIndex-1]
    }
}

//
//  CalendarModel.swift
//
//
//  Created by Kerim Çağlar on 24.09.2024.
//

import Foundation

public enum CalendarModel {
    
    public struct Year: Equatable {
        public let year: Int
        public var months: [Month]
    }
    
    public struct Month: Equatable {
        public let month: Int
        public var days: [Day]
    }
    
    public struct Day: Equatable {
        
        public enum DateType {
            case previousMonth
            case nextMonth
            case currentMonth
        }
        
        public enum RangeType: Equatable {
            case outOfRange(DateType)
            case insideRange(DateType)
            
            var dateType: DateType {
                switch self {
                case .outOfRange(let dateType), .insideRange(let dateType):
                    dateType
                }
            }
            
            public var isOutOfRange: Bool {
                switch self {
                case .outOfRange:
                    true
                case .insideRange:
                    false
                }
            }
            
            public var isInsideRange: Bool {
                switch self {
                case .outOfRange:
                    false
                case .insideRange:
                    true
                }
            }
        }
        
        public let day: Int
        public let date: Date
        public let rangeType: RangeType
        
        public var isCurrentMonth: Bool {
            rangeType.dateType == .currentMonth
        }
        
        /// isCurrentMonth && insideRange
        public var isInRangeCurrentMonth: Bool {
            rangeType.dateType == .currentMonth
            && rangeType.isInsideRange
        }
        
        public var isPreviousMonth: Bool {
            rangeType.dateType == .previousMonth
        }
        
        /// isPreviousMonth && insideRange
        public var isInRangePreviousMonth: Bool {
            rangeType.dateType == .previousMonth
            && rangeType.isInsideRange
        }
        
        public var isNextMonth: Bool {
            rangeType.dateType == .nextMonth
        }
        
        /// isNextMonth && insideRange
        public var isInRangeNextMonth: Bool {
            rangeType.dateType == .nextMonth
            && rangeType.isInsideRange
        }
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

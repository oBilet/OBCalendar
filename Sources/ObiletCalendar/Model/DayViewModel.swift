//
//  DayViewModel.swift
//  OBCalendar
//
//  Created by Metin Tarık Kiki on 29.08.2025.
//

import Foundation

public extension CalendarModel {
    
    struct DayViewModel {
        
        public enum DateRangeComparisonResult {
            case equalToLhs
            case equalToRhs
            case insideRange
            case outOfRangeLessThanLhs
            case outOfRangeMoreThanRhs
            case nilLhs
            case nilRhs
            case nilRange
        }
        
        public let day: CalendarModel.Day
        public let month: CalendarModel.Month
        public let year: CalendarModel.Year
        public let calendar: Calendar
        
        public var isOutOfRange: Bool {
            day.rangeType.isOutOfRange
        }
        
        public var isPast: Bool {
            calendar.compare(day.date, to: Date(), toGranularity: .day) == .orderedAscending
        }
        
        public func compareDay(to date: Date?) -> ComparisonResult? {
            guard let date else { return nil }
            return calendar.compare(day.date, to: date, toGranularity: .day)
        }
        
        public func isEqualDay(with date: Date?) -> Bool {
            guard let date else { return false }
            return calendar.compare(date, to: day.date, toGranularity: .day) == .orderedSame
        }
        
        public func isEqualDay(with dayModel: CalendarModel.Day?) -> Bool {
            guard let dayModel else { return false }
            return isEqualDay(with: dayModel.date)
        }
        
        public func isBetweenDates(
            lhsDate: Date?,
            rhsDate: Date?
        ) -> DateRangeComparisonResult {
            
            if lhsDate == nil {
                return rhsDate == nil
                ? .nilRange
                : .nilLhs
            } else if rhsDate == nil {
                return .nilRhs
            }
            
            let lhsDate = lhsDate!
            let rhsDate = rhsDate!
            
            let lhsComparison = calendar.compare(day.date, to: lhsDate, toGranularity: .day)
            
            return switch lhsComparison {
            case .orderedAscending:
                    .outOfRangeLessThanLhs
                
            case .orderedDescending:
                switch calendar.compare(day.date, to: rhsDate, toGranularity: .day) {
                case .orderedAscending:
                        .insideRange
                case .orderedDescending:
                        .outOfRangeMoreThanRhs
                case .orderedSame:
                        .equalToRhs
                }
                
            case .orderedSame:
                    .equalToLhs
            }
        }
        
        public func isBetweenDays(
            lhsDay: CalendarModel.Day,
            rhsDay: CalendarModel.Day
        ) -> DateRangeComparisonResult {
            isBetweenDates(lhsDate: lhsDay.date, rhsDate: rhsDay.date)
        }
    }
}

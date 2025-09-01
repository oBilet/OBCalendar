//
//  MonthViewModel.swift
//  OBCalendar
//
//  Created by Metin Tarık Kiki on 29.08.2025.
//

import Foundation

public extension CalendarModel {
    
    struct MonthViewModel {
        
        public let month: CalendarModel.Month
        public let year: CalendarModel.Year
        public let calendar: Calendar
        
        private var monthSymbolIndex: Int {
            month.month-1
        }
        
        public var monthSymbol: String {
            calendar.monthSymbols[monthSymbolIndex]
        }
        
        public var shortMonthSymbol: String {
            calendar.shortMonthSymbols[monthSymbolIndex]
        }
        
        public var standaloneMonthSymbol: String {
            calendar.standaloneMonthSymbols[monthSymbolIndex]
        }
        
        public var veryShortMonthSymbol: String {
            calendar.veryShortMonthSymbols[monthSymbolIndex]
        }
        
        public var shortStandaloneMonthSymbol: String {
            calendar.shortStandaloneMonthSymbols[monthSymbolIndex]
        }
        
        public var veryShortStandaloneMonthSymbol: String {
            calendar.veryShortStandaloneMonthSymbols[monthSymbolIndex]
        }
        
        public var yearString: String {
            year.year.toString(format: .none) ?? ""
        }
        
        public var title: String {
            monthSymbol + " " + yearString
        }
    }
}

public extension CalendarModel {
    
    struct YearViewModel {
        
        public let year: CalendarModel.Year
        public let calendar: Calendar
    }
}

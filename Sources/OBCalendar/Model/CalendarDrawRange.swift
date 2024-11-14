//
//  CalendarDrawRange.swift
//  
//
//  Created by Metin Tarık Kiki on 14.11.2024.
//

import Foundation

public enum CalendarDrawRange {
    
    public struct CalendarTarget {
        let component: Calendar.Component
        let value: Int
    }
    
    case day(_ value: Int)
    case month(_ value: Int)
    case year(_ value: Int)
    
    public var calendarTarget: CalendarTarget {
        switch self {
        case .day(let value):
                .init(component: .day, value: value)
        case .month(let value):
                .init(component: .month, value: value)
        case .year(let value):
                .init(component: .year, value: value)
        }
    }
}

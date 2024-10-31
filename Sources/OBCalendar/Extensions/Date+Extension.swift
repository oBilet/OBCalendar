//
//  Date+Extension.swift
//  
//
//  Created by Metin Tarık Kiki on 30.09.2024.
//

import Foundation

extension Date {
    
    func isLastDayOfMonth(calendar: Calendar) -> Bool {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: self)
        return tomorrow?.isFirstDayOfMonth(calendar: calendar) ?? false
    }
    
    func isFirstDayOfMonth(calendar: Calendar) -> Bool {
        calendar.component(.day, from: self) == 1
    }
}

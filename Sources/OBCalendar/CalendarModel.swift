//
//  CalendarModel.swift
//
//
//  Created by Kerim Çağlar on 24.09.2024.
//

import Foundation

public enum CalendarModel {
    
    struct Year {
        let year: Int
        let months: [Month]
    }
    
    struct Month {
        let month: Int
        let days: [Day]
    }
    
    struct Day {
        let day: Int
        let date: Date
    }
}

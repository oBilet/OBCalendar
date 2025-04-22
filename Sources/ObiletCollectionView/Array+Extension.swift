//
//  Array+Extension.swift
//  OBCalendar
//
//  Created by Metin Tarık Kiki on 16.04.2025.
//

import Foundation

extension Array {
    
    func isValid(index: Int) -> Bool {
        !isEmpty && index >= startIndex && index < endIndex
    }
}

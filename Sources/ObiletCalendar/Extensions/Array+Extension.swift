//
//  Array+Extension.swift
//  
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import Foundation

extension Array {
    
    func shifted(by offset: Int) -> Self {
        let offsetMod = offset % self.count
        return Array(self[offsetMod..<self.count] + self[0..<offsetMod])
    }
}

//
//  Task+Extension.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

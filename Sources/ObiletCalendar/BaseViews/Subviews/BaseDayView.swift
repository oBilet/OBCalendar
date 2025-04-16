//
//  BaseDayView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public protocol BaseCalendarDayViewProtocol: View {
    
    init(
        model: (
            year: CalendarModel.Year,
            month: CalendarModel.Month,
            day: CalendarModel.Day
        )
    )
}

public struct BaseCalendarDayView: BaseCalendarDayViewProtocol {
    
    @ViewBuilder
    public static func makeDayView(
        model: CalendarModel.Day,
        placeholder: some View = Color.clear
    ) -> some View {
        if isCurrentMonth(model: model) {
            Text("\(model.day)")
                .font(.system(size: 15))
        } else {
            placeholder
        }
    }
    
    private static func isCurrentMonth(model: CalendarModel.Day) -> Bool {
        if case .insideRange(.currentMonth) = model.rangeType {
            true
        } else {
            false
        }
    }
    
    let model: (year: CalendarModel.Year, month: CalendarModel.Month, day: CalendarModel.Day)
    let placeholderView = Color.clear
    
    public init(
        model: (
            year: CalendarModel.Year,
            month: CalendarModel.Month,
            day: CalendarModel.Day
        )
    ) {
        self.model = model
    }
    
    public var body: some View {
        Self.makeDayView(
            model: model.day,
            placeholder: placeholderView
        )
        .frame(width: 32, height: 32)
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    CalendarBuilder(
//        calendar: .current,
//        scrollTrigger: .constant("")
//    )
//    .build()
//}

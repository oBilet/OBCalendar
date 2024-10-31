//
//  BaseDayView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public enum BaseCalendarDayViewDefaults {
    public static let defaultPlaceholder = Color.clear
}

public struct BaseCalendarDayView<Placeholder: View>: View {
    
    @ViewBuilder
    public static func makeDayView(
        model: CalendarModel.Day,
        placeholder: some View = BaseCalendarDayViewDefaults.defaultPlaceholder
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
    let calendar: Calendar
    
    let placeholder: Placeholder
    
    public init(
        placeholder: Placeholder,
        model: (year: CalendarModel.Year, month: CalendarModel.Month, day: CalendarModel.Day),
        calendar: Calendar
    ) {
        self.placeholder = placeholder
        self.model = model
        self.calendar = calendar
    }
    
    public init(
        placeholder: Placeholder = Color.clear,
        model: (year: CalendarModel.Year, month: CalendarModel.Month, day: CalendarModel.Day),
        calendar: Calendar
    ) where Placeholder == Color {
        self.placeholder = placeholder
        self.model = model
        self.calendar = calendar
    }
    
    public var body: some View {
        let targetView = dayView
            .frame(width: 32, height: 32)
        
        ContentBuilder.build {
            if isDateOlder {
                targetView
                    .opacity(0.3)
            } else {
                targetView
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var dayView: some View {
        Self.makeDayView(model: model.day)
    }
    
    private var isDateOlder: Bool {
        calendar.compare(model.day.date, to: Date(), toGranularity: .day) == .orderedAscending
    }
}

//#Preview {
//    CalendarBuilder(
//        calendar: .current,
//        scrollTrigger: .constant("")
//    )
//    .build()
//}

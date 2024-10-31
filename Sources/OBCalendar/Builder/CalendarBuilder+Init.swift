//
//  CalendarBuilder+Init.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public typealias DefaultDayContent = BaseCalendarDayView<Color>
public typealias DefaultMonthContent = BaseCalendarMonthView<OBCollectionView<_ConditionalContent<BaseCalendarDayView<Color>, _ConditionalContent<BaseCalendarDayView<Color>, Color>>, CalendarModel.Day>>
public typealias DefaultYearContent = BaseCalendarYearView<OBCollectionView<BaseCalendarMonthView<OBCollectionView<_ConditionalContent<BaseCalendarDayView<Color>, _ConditionalContent<BaseCalendarDayView<Color>, Color>>, CalendarModel.Day>>, CalendarModel.Month>>

public extension CalendarBuilder
where DayContent == DefaultDayContent,
      MonthContent == DefaultMonthContent,
      YearContent == DefaultYearContent
{
    init(
        startDate: Date = Date(),
        yearLimit: Int = 1,
        calendar: Calendar,
        scrollTrigger: Binding<ScrollIdType?>,
        includeBlanks: Bool = false
    ) {
        self.init(
            startDate: startDate,
            yearLimit: yearLimit,
            calendar: calendar,
            scrollTrigger: scrollTrigger,
            includeBlanks: includeBlanks
        ) { baseView, model in
            baseView
        } monthContent: { baseView, daysView, model in
            baseView
        } yearContent: { baseView, monthsView, model in
            baseView
        }
    }
}

#Preview("Default") {
    CalendarBuilder(
        calendar: .current,
        scrollTrigger: .constant("")
    )
    .build()
}

#Preview("Day Modifier") {
    CalendarBuilder(
        calendar: .current,
        scrollTrigger: .constant(""),
        includeBlanks: false
    )
    .dayModifier({ baseView, model in
        baseView
            .background(Color.blue)
            .padding(2)
            .foregroundColor(.white)
    })
    .build()
}

#Preview("Month Modifier") {
    CalendarBuilder(
        calendar: .current,
        scrollTrigger: .constant("")
    )
    .monthModifier({ baseView, daysView, model in
        VStack {
            Text("Modified Months")
            daysView
        }
        .padding()
    })
    .build()
}

#Preview("Modified Day + Modified Month") {
    CalendarBuilder(
        calendar: .current,
        scrollTrigger: .constant("")
    )
    .dayModifier({ baseView, model in
        baseView
            .foregroundColor(Color(.red))
    })
    .monthModifier({ baseView, daysView, model in
        VStack {
            Text("Modified Months")
            daysView
        }
        .padding()
    })
    .build()
}

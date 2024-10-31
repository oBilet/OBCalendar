//
//  CalendarBuilder+Init.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public typealias DefaultDayContent = CalendarDayView<Color>
public typealias DefaultMonthContent = CalendarMonthView<OBCollectionView<CalendarDayView<Color>, CalendarModel.Day>>
public typealias DefaultYearContent = CalendarYearView<OBCollectionView<CalendarMonthView<OBCollectionView<CalendarDayView<Color>, CalendarModel.Day>>, CalendarModel.Month>>

public extension CalendarBuilder
where DayContent == DefaultDayContent,
      MonthContent == DefaultMonthContent,
      YearContent == DefaultYearContent
{
    init(
        startDate: Date = Date(),
        yearLimit: Int = 1,
        calendar: Calendar,
        scrollTrigger: Binding<ScrollIdType?>
    ) {
        self.init(
            startDate: startDate,
            yearLimit: yearLimit,
            calendar: calendar,
            scrollTrigger: scrollTrigger
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
        scrollTrigger: .constant("")
    )
    .dayModifier({ baseView, model in
        baseView
            .foregroundColor(Color(.red))
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

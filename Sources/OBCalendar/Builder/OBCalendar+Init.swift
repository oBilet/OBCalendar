//
//  OBCalendar+Init.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public typealias DefaultDayContent = BaseCalendarDayView
public typealias DefaultMonthContent = BaseCalendarMonthView<OBCollectionView<_ConditionalContent<BaseCalendarDayView, _ConditionalContent<BaseCalendarDayView, Color>>, CalendarModel.Day>>
public typealias DefaultYearContent = BaseCalendarYearView<OBCollectionView<BaseCalendarMonthView<OBCollectionView<_ConditionalContent<BaseCalendarDayView, _ConditionalContent<BaseCalendarDayView, Color>>, CalendarModel.Day>>, CalendarModel.Month>>

public extension OBCalendar
where DayContent == DefaultDayContent,
      MonthContent == DefaultMonthContent,
      YearContent == DefaultYearContent
{
    init(
        startDate: Date = Date(),
        drawingRange: CalendarDrawRange = .year(1),
        calendar: Calendar = .current,
        includeBlanks: Bool = false,
        lazyYears: Bool = false,
        lazyMonths: Bool = false,
        lazyDays: Bool = false,
        dayScrollEnabled: Bool = false,
        dayScrollAxis: Axis.Set = .vertical,
        dayGridItems: [GridItem] = Array(0..<7).map { _ in .init(spacing: .zero) }, // 7 day columns by default
        monthScrollEnabled: Bool = false,
        monthScrollAxis: Axis.Set = .vertical,
        monthGridItems: [GridItem] = [.init()],
        yearScrollEnabled: Bool = true,
        yearScrollAxis: Axis.Set = .vertical,
        yearGridItems: [GridItem] = [.init()]
    ) {
        self.init(
            startDate: startDate,
            drawingRange: drawingRange,
            calendar: calendar,
            includeBlanks: includeBlanks,
            lazyYears: lazyYears,
            lazyMonths: lazyMonths,
            lazyDays: lazyDays,
            dayScrollEnabled: dayScrollEnabled,
            dayScrollAxis: dayScrollAxis,
            dayGridItems: dayGridItems,
            monthScrollEnabled: monthScrollEnabled,
            monthScrollAxis: monthScrollAxis,
            monthGridItems: monthGridItems,
            yearScrollEnabled: yearScrollEnabled,
            yearScrollAxis: yearScrollAxis,
            yearGridItems: yearGridItems
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
    OBCalendar(drawingRange: .day(30))
}

#Preview("Horizontal") {
    GeometryReader { geometry in
        OBCalendar(
            includeBlanks: false,
            monthScrollAxis: .horizontal,
            yearScrollAxis: .horizontal
        )
        .dayModifier { baseView, model in
            baseView
                .foregroundColor(.white)
                .background(Color.blue)
        }
        .monthModifier { baseView, daysView, model in
            HStack(spacing: .zero) {
                baseView
                    .padding()
                Divider()
            }
            .frame(width: geometry.size.width)
        }
    }
}

#Preview("Day Modifier") {
    OBCalendar(includeBlanks: true)
        .dayModifier { baseView, model in
            baseView
                .background(Color.blue)
                .padding(2)
                .foregroundColor(.white)
        }
}

#Preview("Month Modifier") {
    OBCalendar()
        .monthModifier{ baseView, daysView, model in
            VStack {
                Text("Modified Months")
                daysView
            }
            .padding()
        }
}

#Preview("Modified Day + Modified Month") {
    OBCalendar()
        .dayModifier { baseView, model in
            baseView
                .foregroundColor(Color(.red))
        }
        .monthModifier { baseView, daysView, model in
            VStack {
                Text("Modified Months")
                daysView
            }
            .padding()
        }
}

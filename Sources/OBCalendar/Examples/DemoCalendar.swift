//
//  DemoCalendar.swift
//  
//
//  Created by Metin Tarık Kiki on 30.09.2024.
//

import SwiftUI

private extension Dictionary where Key == Date?, Value == String {
    
    func yearExists(year: Int, calendar: Calendar) -> Bool {
        self.contains { element in
            if let date = element.key {
                year == calendar.component(.year, from: date)
            } else {
                false
            }
        }
    }
    
    func get(year: Int, month: Int, day: Int, calendar: Calendar) -> Dictionary<Date?, String>.Element? {
        self.first(where: { element in
            if let date = element.key {
                year == calendar.component(.year, from: date)
                && month == calendar.component(.month, from: date)
                && day == calendar.component(.day, from: date)
            } else {
                false
            }
        })
    }
    
    func contains(date: Date) -> Bool {
        self.contains { element in
            element.key == date
        }
    }
}

private extension DemoCalendar {
    
    static func makeSpecialDays(calendar: Calendar) -> [Date?: String] {
        [
            calendar.date(from: DateComponents(year: 2025, month: 1, day: 1)): "New Year's Day",
            calendar.date(from: DateComponents(year: 2025, month: 4, day: 23)): "National Sovereignty and Children's Day",
            calendar.date(from: DateComponents(year: 2025, month: 5, day: 1)): "Labor and Solidarity Day",
            calendar.date(from: DateComponents(year: 2025, month: 8, day: 30)): "Victory Day",
            calendar.date(from: DateComponents(year: 2025, month: 10, day: 29)): "Republic Day"
        ]
    }
}

struct DemoCalendar: View {
    
    @State var specialDaysVisible = false
    @State var doubleSelection = false
    @State var firstSelectedDate: Date?
    @State var secondSelectedDate: Date?

    let specialDays: [Date?: String]
    
    let calendar: Calendar
    
    let selectedBetweenBackground = Color(UIColor.systemGreen.withAlphaComponent(0.25))
    let selectedBackground: some View = Circle()
        .foregroundColor(.green)
    
    init(calendar: Calendar) {
        self.specialDays = Self.makeSpecialDays(calendar: calendar)
        self.calendar = calendar
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            specialDaysSwitch
                .fixedSize()
            
            selectionSwitch
                .fixedSize()
            
            headerView
                .fixedSize(horizontal: false, vertical: true)
                .padding(8)
                .background(Color.red)
                .foregroundColor(.white)
            
            daysView
                .padding(4)
                .background(Color.white)
                .compositingGroup()
                .shadow(color: .gray, radius: 1, x: 0, y: 2)
            
            calendarView
        }
    }
    
    var selectionSwitch: some View {
        Toggle(isOn: $doubleSelection) {
            Text("Double Selection")
        }
        .onChange(of: doubleSelection) { _ in
            firstSelectedDate = nil
            secondSelectedDate = nil
        }
    }
    
    var specialDaysSwitch: some View {
        Toggle(isOn: $specialDaysVisible) {
            Text("Special Days")
        }
    }
    
    var headerView: some View {
        HStack {
            Image(systemName: "calendar")
            Text("Departure Date")
            Spacer()
            Divider()
            Image(systemName: "checkmark")
            Text("APPLY")
        }
    }
    
    var daysView: some View {
        let days = getShortLocalizedWeekdays(for: calendar)
        return HStack {
            ForEach(days.indices, id: \.self) { index in
                Text(days[index])
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    var calendarView: some View {
        OBCalendar()
            .dayModifier { baseView, model in
                dayContent(baseView: baseView, model: model.day)
            }
            .monthModifier { baseView, daysView, model in
                monthContent(
                    baseView: baseView,
                    monthModel: model.month,
                    yearModel: model.year
                )
            }
    }
    
    @ViewBuilder
    func dayContent(baseView: some View, model: CalendarModel.Day) -> some View {
        let dayView = modifyDayView(
            model: model,
            content: { baseView }
        )
        .padding(.vertical, 4)
        .onTapGesture {
            if doubleSelection {
                selectDouble(date: model.date)
            } else {
                selectSingle(date: model.date)
            }
        }
        
        
        if specialDays.contains(date: model.date),
           specialDaysVisible {
            dayView
                .overlay(
                    VStack(alignment: .trailing) {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 6, height: 6)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Spacer()
                    }.padding(12)
                )
        } else {
            dayView
        }
    }
    
    @ViewBuilder
    func monthContent(
        baseView: some View,
        monthModel: CalendarModel.Month,
        yearModel: CalendarModel.Year
    ) -> some View {
        VStack {
            baseView
            
            if specialDaysVisible {
                makeSpecialDaysView(year: yearModel.year, month: monthModel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    func makeSpecialDaysView(year: Int, month: CalendarModel.Month) -> some View {
        if specialDays.yearExists(year: year, calendar: calendar) {
            ForEach(month.days.indices, id: \.self) { index in
                let day = month.days[index]
                if case .insideRange(.currentMonth) = day.rangeType,
                   let specialDay = specialDays.get(
                    year: year,
                    month: month.month,
                    day: day.day,
                    calendar: calendar
                ) {
                    HStack {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.blue)
                        
                        Text(specialDay.value)
                    }
                }
            }
        }
    }
    
    func selectSingle(date: Date) {
        secondSelectedDate = nil
        firstSelectedDate = date
    }
    
    func selectDouble(date: Date) {
        if firstSelectedDate == nil {
            firstSelectedDate = date
        } else if secondSelectedDate == nil {
            if let firstSelectedDate,
                date < firstSelectedDate {
                secondSelectedDate = firstSelectedDate
                self.firstSelectedDate = date
            } else {
                secondSelectedDate = date
            }
        } else {
            firstSelectedDate = date
            secondSelectedDate = nil
        }
    }
    
    @ViewBuilder
    func modifySelectedDayView<Content: View>(
        date: Date,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let modifiedContent = content()
            .background(
                selectedBackground
            )
            .foregroundColor(.white)
        
        let isFirstSelected = date == firstSelectedDate && secondSelectedDate != nil
        let isSingleSelected = firstSelectedDate == nil || secondSelectedDate == nil
        
        if isSingleSelected {
            modifiedContent
        } else {
            modifiedContent
                .background(
                    HStack {
                        if isFirstSelected {
                            Color.clear
                                .frame(maxWidth: .infinity)
                            selectedBetweenBackground
                                .frame(maxWidth: .infinity)
                        } else {
                            selectedBetweenBackground
                                .frame(maxWidth: .infinity)
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                )
        }
    }
    
    @ViewBuilder
    func modifyBetweenSelectedDateView<Content: View>(
        date: Date,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if let firstSelectedDate,
            let secondSelectedDate,
            date > firstSelectedDate && date < secondSelectedDate {
            content()
                .background(
                    selectedBetweenBackground
                )
        } else {
            content()
        }
    }
    
    @ViewBuilder
    func modifyDayView<Content: View>(
        model: CalendarModel.Day,
        @ViewBuilder content: () -> Content
    ) -> some View {
        
        if model.date == firstSelectedDate || model.date == secondSelectedDate {
            
            modifySelectedDayView(
                date: model.date,
                content: content
            )
            
        } else {
            modifyBetweenSelectedDateView(
                date: model.date,
                content: content
            )
        }
    }
    
    func getShortLocalizedWeekdays(
        for calendar: Calendar
    ) -> [String] {
        let firstWeekday = calendar.firstWeekday
        
        let shortWeekdays = calendar.shortWeekdaySymbols
        let firstWeekdayIndex = firstWeekday - 1
        
        let reorderedShortWeekdays = Array(shortWeekdays[firstWeekdayIndex...])
        + Array(shortWeekdays[..<firstWeekdayIndex])
        
        return reorderedShortWeekdays
    }
}

#Preview {
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "en_US")
    return DemoCalendar(calendar: calendar)
}

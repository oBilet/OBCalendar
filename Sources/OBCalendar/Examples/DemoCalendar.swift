//
//  DemoCalendar.swift
//  
//
//  Created by Metin Tarık Kiki on 30.09.2024.
//

import SwiftUI

private struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Dictionary where Key == Date?, Value == String {
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
    
    static func getYears(from calendar: Calendar) -> [CalendarModel.Year] {
        let today = Date()
        let todayComponents = DateComponents(
            year: calendar.component(.year, from: today),
            month: calendar.component(.month, from: today),
            day: 1
        )
        let firstDayOfMonth = calendar.date(from: todayComponents)!
        let nextYear = calendar.date(byAdding: .year, value: 1, to: firstDayOfMonth)
        return CalendarModelBuilder.defaultLayout(
            calendar: calendar,
            startDate: firstDayOfMonth,
            endDate: nextYear!
        )
    }
}

struct DemoCalendar: View {
    
    @State var specialDaysVisible = false
    @State var doubleSelection = false
    @State var firstSelectedDate: Date?
    @State var secondSelectedDate: Date?
    
    let years: [CalendarModel.Year]
    let specialDays: [Date?: String]
    
    let calendar: Calendar
    
    let selectedBetweenBackground = Color(UIColor.systemGreen.withAlphaComponent(0.25))
    let selectedBackground: some View = Circle()
        .foregroundColor(.green)
    
    init(calendar: Calendar) {
        self.years = Self.getYears(from: calendar)
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
        OBBaseCalendar(
            years: years
        ) { model,scrollProxy in
            
            let dayView = modifyDayView(model: model.day) {
                Text("\(model.day.day)")
                    .frame(height: 35)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 4)
            .onTapGesture {
                if doubleSelection {
                    selectDouble(date: model.day.date)
                } else {
                    selectSingle(date: model.day.date)
                }
            }
            
            
            if case .insideRange(.currentMonth) = model.day.rangeType,
               specialDays.contains(date: model.day.date),
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
            
        } monthContent: { model, scrollProxy, daysView in
            VStack {
                HStack {
                    Text(getMonthName(from: model.month.month))
                    Text(formatYear(model.year.year))
                }
                .padding(8)
                
                Divider()
                
                daysView
                
                if specialDaysVisible {
                    makeSpecialDaysView(year: model.year.year, month: model.month)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        } yearContent: { year, scrollProxy, monthsView in
            monthsView
                .padding(.top, 8)
        }
    }
    
    func makeSpecialDaysView(year: Int, month: CalendarModel.Month) -> some View {
        contentBuilder {
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
    
    func modifySelectedDayView<Content: View>(date: Date, @ViewBuilder content: () -> Content) -> some View {
        contentBuilder {
            
            let modifiedContent = content()
                .background(
                    selectedBackground
                )
                .foregroundColor(.white)
            
            let isFirstSelected = date == firstSelectedDate && secondSelectedDate != nil
            let isSecondSelected = date == secondSelectedDate && firstSelectedDate != nil
            let isSingleSelected = firstSelectedDate == nil || secondSelectedDate == nil
            
            let config: (corners: UIRectCorner, edges: Edge.Set) = isFirstSelected
            ? ([.topLeft, .bottomLeft], .leading)
            : isSecondSelected
            ? ([.topRight, .bottomRight], .trailing)
            : ([], .all)
            
            if isSingleSelected {
                modifiedContent
            } else {
                modifiedContent
                    .background(
                        selectedBetweenBackground
                            .clipShape(
                                RoundedCornersShape(corners: config.corners, radius: 17.5)
                            )
                            .padding(config.edges)
                    )
            }
        }
    }
    
    func modifyBetweenSelectedDateView<Content: View>(date: Date, @ViewBuilder content: () -> Content) -> some View {
        contentBuilder {
            
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
    }
    
    func modifyDayView<Content: View>(
        model: CalendarModel.Day,
        @ViewBuilder content: () -> Content
    ) -> some View {
        contentBuilder {
            if case .insideRange(.currentMonth) = model.rangeType {
                
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
            } else {
                if model.isInRangePreviousMonth {
                    Color.red
                } else if model.isInRangeNextMonth {
                    Color.green
                } else {
                    Color.blue
                }
            }
        }
    }
    
    func formatYear(_ year: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        return numberFormatter.string(from: NSNumber(value: year)) ?? ""
    }
    
    func makeDate(from month: Int) -> Date {
        let components = DateComponents(month: month)
        return calendar.date(from: components) ?? Date()
    }
    
    func getMonthName(
        from month: Int
    ) -> String {
        let date = makeDate(from: month)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: calendar.locale?.identifier ?? "")
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: date)
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
    
    private func contentBuilder<Content: View>(@ViewBuilder content: () -> Content) -> Content {
        content()
    }
}

#Preview {
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "en_US")
    return DemoCalendar(calendar: calendar)
}

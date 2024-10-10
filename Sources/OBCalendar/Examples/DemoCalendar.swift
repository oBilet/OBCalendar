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

private extension DemoCalendar {
    static func getYears(from calendar: Calendar) -> [CalendarModel.Year] {
        let today = Date()
        let todayComponents = DateComponents(
            year: calendar.component(.year, from: today),
            month: calendar.component(.month, from: today),
            day: 1
        )
        let startingDayOfMonth = calendar.date(from: todayComponents)!
        let nextYear = calendar.date(byAdding: .year, value: 1, to: startingDayOfMonth)
        return CalendarModelBuilder.defaultLayout(
            calendar: calendar,
            startingDate: startingDayOfMonth,
            endingDate: nextYear!
        )
    }
}

struct DemoCalendar: View {
    
    @State var doubleSelection = false
    @State var firstSelectedDate: Date?
    @State var secondSelectedDate: Date?
    
    let years: [CalendarModel.Year]
    
    let calendar: Calendar
    
    let selectedBetweenBackground = Color(UIColor.systemGreen.withAlphaComponent(0.25))
    let selectedBackground: some View = Circle()
        .foregroundColor(.green)
    
    init(calendar: Calendar) {
        self.years = Self.getYears(from: calendar)
        self.calendar = calendar
    }
    
    var body: some View {
        VStack {
            Spacer()
            
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
        contentBuilder {
            Toggle(isOn: $doubleSelection) {
                Text("Double Selection")
            }
            .onChange(of: doubleSelection) { _ in
                firstSelectedDate = nil
                secondSelectedDate = nil
            }
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
        OBCalendar(
            years: years,
            lazyDays: true
        ) { model,scrollProxy in
            
            modifyDayView(model: model.day) {
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
            
        } monthContent: { model, scrollProxy, daysView in
            VStack {
                HStack {
                    Text(getMonthName(from: model.month.month))
                    Text(formatYear(model.year.year))
                }
                .padding(8)
                
                Divider()
                
                daysView
            }
        } yearContent: { year, scrollProxy, monthsView in
            monthsView
                .padding(.top, 8)
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
                Color.clear
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

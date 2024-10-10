//
//  DemoCalendar.swift
//  
//
//  Created by Metin Tarık Kiki on 30.09.2024.
//

import SwiftUI

private extension DemoCalendar {
    private static func getYears(from calendar: Calendar) -> [CalendarModel.Year] {
        let today = Date()
        let nextYear = calendar.date(byAdding: .year, value: 1, to: today)
        return CalendarModelBuilder.defaultLayout(
            calendar: calendar,
            startingDate: today,
            endingDate: nextYear!
        )
    }
}

struct DemoCalendar: View {
    
    let years: [CalendarModel.Year]
    
    @State var selectedDate: Date?
    
    let calendar: Calendar
    
    init(calendar: Calendar) {
        self.years = Self.getYears(from: calendar)
        self.calendar = calendar
    }
    
    var body: some View {
        VStack {
            Spacer()
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
        OBCalendar(years: years) { model,scrollProxy in 
            ZStack {
                let day = model.day
                if case .insideRange(.currentMonth) = model.day.rangeType {
                    Text("\(day.day)")
                        .foregroundColor(
                            selectedDate == day.date
                            ? .white
                            : .black
                        )
                } else {
                    Color.clear
                }
            }
            .frame(width: 35, height: 35)
            .background(
                ContentBuilder.buildContent {
                    if selectedDate == model.day.date,
                       case .insideRange(.currentMonth) = model.day.rangeType {
                        Circle()
                            .foregroundColor(.green)
                    }
                }
            )
            .onTapGesture {
                selectedDate = model.day.date
            }
            
        } monthContent: { model, scrollProxy, daysView in
            VStack {
                HStack {
                    Text(getMonthName(from: model.month.month))
                    Text(formatYear(model.year.year))
                }
                
                Divider()
                
                daysView
            }
        } yearContent: { year, scrollProxy, monthsView in
            monthsView
                .padding(.top, 8)
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
}

#Preview {
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "tr_US")
    return DemoCalendar(calendar: calendar)
}

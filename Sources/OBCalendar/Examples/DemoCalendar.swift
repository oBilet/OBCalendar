//
//  DemoCalendar.swift
//  
//
//  Created by Metin Tarık Kiki on 30.09.2024.
//

import SwiftUI

struct DemoCalendar: View {
    
    let years: [CalendarModel.Year] = {
        let today = Date()
        let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: today)
        return CalendarModelBuilder.defaultLayout(
            startingDate: today,
            endingDate: nextYear!
        )
    }()
    
    @State var selectedDate: Date?
    
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
        let days = getShortLocalizedWeekdays()
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
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func getMonthName(
        from month: Int,
        localeIdentifier: String = "en_US"
    ) -> String {
        let date = makeDate(from: month)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: localeIdentifier)
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: date)
    }
    
    func getShortLocalizedWeekdays(for localeIdentifier: String = "en_US") -> [String] {
        // Create a Locale object from the localeIdentifier string
        let locale = Locale(identifier: localeIdentifier)
        
        // Use the default calendar and set the locale
        var calendar = Calendar.current
        calendar.locale = locale
        
        // Get the index of the first weekday (e.g., Sunday = 1, Monday = 2)
        let firstWeekday = calendar.firstWeekday
        
        // Get the localized short names of the weekdays (e.g., "Mon", "Tue", "Wed")
        let shortWeekdays = calendar.shortWeekdaySymbols
        
        // Rearrange the weekdays starting from the first weekday
        let firstWeekdayIndex = firstWeekday - 1 // Adjust because firstWeekday is 1-based
        let reorderedShortWeekdays = Array(shortWeekdays[firstWeekdayIndex...]) + Array(shortWeekdays[..<firstWeekdayIndex])
        
        // Return the reordered short weekday names
        return reorderedShortWeekdays
    }
}

#Preview {
    DemoCalendar()
}

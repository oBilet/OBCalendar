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
            Text("Gidiş Tarihi")
            Spacer()
            Divider()
            Image(systemName: "checkmark")
            Text("UYGULA")
        }
    }
    
    var daysView: some View {
        let days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
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
                if day.dateType == .currentMonth {
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
                    if selectedDate == model.day.date
                        && model.day.dateType == .currentMonth {
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
        localeIdentifier: String = "tr_TR"
    ) -> String {
        let date = makeDate(from: month)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: localeIdentifier)
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    DemoCalendar()
}

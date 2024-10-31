//
//  BaseMonthView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

private extension Int {
    var noneFormattedString: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter.string(from: NSNumber(integerLiteral: self))
    }
    
    func toString(format: NumberFormatter.Style) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter.string(from: NSNumber(integerLiteral: self))
    }
}

public struct CalendarMonthView<
    DayContent: View
>: View {
    
    private let padding: CGFloat = 12
    
    let model: (year: CalendarModel.Year, month: CalendarModel.Month)
    let daysView: DayContent
    let calendar: Calendar
    
    public init(
        model: (year: CalendarModel.Year, month: CalendarModel.Month),
        daysView: DayContent,
        calendar: Calendar
    ) {
        self.model = model
        self.daysView = daysView
        self.calendar = calendar
    }
    
    public var body: some View {
        VStack {
            VStack {
                monthHeaderView
                daysView
            }
            .padding(.horizontal, padding)
            
            Divider()
                .padding(.top, 16)
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var monthHeaderView: some View {
        let monthSymbol = calendar.monthSymbols[model.month.month-1]
        let yearText = model.year.year.toString(format: .none) ?? ""
        let monthText = "\(monthSymbol) \(yearText)"
        HStack {
            Text(monthText)
                .font(.system(size: 13))
            Spacer()
        }
        .padding(.horizontal)
    }
}

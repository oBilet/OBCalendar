//
//  BaseMonthView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

internal extension Int {
    
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

public protocol BaseCalendarMonthViewProtocol<DayContent>: View {
    
    associatedtype DayContent: View
    
    init(
        viewModel: CalendarModel.MonthViewModel,
        daysView: DayContent,
        calendar: Calendar
    )
}

public struct BaseCalendarMonthView<DayContent: View>: BaseCalendarMonthViewProtocol {
    
    private let padding: CGFloat = 12
    
    let viewModel: CalendarModel.MonthViewModel
    let daysView: DayContent
    
    public init(
        viewModel: CalendarModel.MonthViewModel,
        daysView: DayContent,
        calendar: Calendar
    ) {
        self.viewModel = viewModel
        self.daysView = daysView
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
        HStack {
            Text(viewModel.title)
                .font(.system(size: 13))
            Spacer()
        }
        .padding(.horizontal)
    }
}

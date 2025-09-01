//
//  BaseDayView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public protocol BaseCalendarDayViewProtocol: View {
    
    init(viewModel: CalendarModel.DayViewModel)
}

public struct BaseCalendarDayView: BaseCalendarDayViewProtocol {
    
    @ViewBuilder
    public static func makeDayView(
        model: CalendarModel.Day,
        placeholder: some View = Color.clear
    ) -> some View {
        if isCurrentMonth(model: model) {
            Text("\(model.day)")
        } else {
            placeholder
        }
    }
    
    private static func isCurrentMonth(model: CalendarModel.Day) -> Bool {
        if case .insideRange(.currentMonth) = model.rangeType {
            true
        } else {
            false
        }
    }
    
    let viewModel: CalendarModel.DayViewModel
    let placeholderView = Color.clear
    
    public init(viewModel: CalendarModel.DayViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Self.makeDayView(
            model: viewModel.day,
            placeholder: placeholderView
        )
        .frame(width: 32, height: 32)
        .frame(maxWidth: .infinity)
    }
}

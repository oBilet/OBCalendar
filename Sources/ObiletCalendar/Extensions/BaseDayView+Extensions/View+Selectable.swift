//
//  View+Selectable.swift
//  OBCalendar
//
//  Created by Metin Tarık Kiki on 1.09.2025.
//

import SwiftUI
import Foundation

public extension View {
    
    func selectable(
        date: Binding<Date?>,
        viewModel: CalendarModel.DayViewModel,
        baseForegroundColor: Color = .primary,
        selectionForegroundColor: Color = .white,
        selectionBackground: some View = Circle().foregroundColor(.blue)
    ) -> some View {
        modifier(
            BaseCalendarDayView.SingleSelectionModifier(
                selectedDate: date,
                viewModel: viewModel,
                baseForegroundColor: baseForegroundColor,
                selectionForegroundColor: selectionForegroundColor,
                selectionBackground: selectionBackground
            )
        )
    }
    
    func selectable(
        lhsDate: Binding<Date?>,
        rhsDate: Binding<Date?>,
        viewModel: CalendarModel.DayViewModel,
        lhsBaseForegroundColor: Color = .primary,
        lhsSelectionForegroundColor: Color = .white,
        lhsSelectionBackground: some View = Circle()
            .frame(maxWidth: .infinity)
            .foregroundColor(.blue),
        rhsBaseForegroundColor: Color = .primary,
        rhsSelectionForegroundColor: Color = .white,
        rhsSelectionBackground: some View = Circle()
            .frame(maxWidth: .infinity)
            .foregroundColor(.blue),
        inRangeForegroundColor: Color = .primary,
        inRangeBackground: some View = Color.blue.opacity(0.5)
    ) -> some View {
        modifier(
            BaseCalendarDayView.RangeSelectionModifier(
                lhsDate: lhsDate,
                rhsDate: rhsDate,
                viewModel: viewModel,
                lhsBaseForegroundColor: lhsBaseForegroundColor,
                lhsSelectionForegroundColor: lhsSelectionForegroundColor,
                lhsSelectionBackground: lhsSelectionBackground,
                rhsBaseForegroundColor: rhsBaseForegroundColor,
                rhsSelectionForegroundColor: rhsSelectionForegroundColor,
                rhsSelectionBackground: rhsSelectionBackground,
                inRangeForegroundColor: inRangeForegroundColor,
                inRangeBackground: inRangeBackground
            )
        )
    }
}

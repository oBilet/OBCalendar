//
//  SingleSelectionModifier.swift
//  OBCalendar
//
//  Created by Metin Tarık Kiki on 1.09.2025.
//

import SwiftUI
import Foundation

internal extension BaseCalendarDayView {
    
    struct SingleSelectionModifier<BackgroundContent: View>: ViewModifier {
        
        @Binding var selectedDate: Date?
        private let viewModel: CalendarModel.DayViewModel
        private let baseForegroundColor: Color
        private let selectionForegroundColor: Color
        private let selectionBackground: BackgroundContent
        
        private var isSelected: Bool {
            viewModel.isEqualDay(with: selectedDate)
        }
        
        init(
            selectedDate: Binding<Date?>,
            viewModel: CalendarModel.DayViewModel,
            baseForegroundColor: Color,
            selectionForegroundColor: Color,
            selectionBackground: BackgroundContent
        ) {
            self._selectedDate = selectedDate
            self.viewModel = viewModel
            self.baseForegroundColor = baseForegroundColor
            self.selectionForegroundColor = selectionForegroundColor
            self.selectionBackground = selectionBackground
        }
        
        func body(content: Content) -> some View {
            let tapableContent = content
                .onTapGesture {
                    selectedDate = viewModel.day.date
                }
            
            if isSelected {
                tapableContent
                    .foregroundColor(selectionForegroundColor)
                    .background(selectionBackground)
            } else {
                tapableContent
                    .foregroundColor(baseForegroundColor)
            }
        }
    }
}

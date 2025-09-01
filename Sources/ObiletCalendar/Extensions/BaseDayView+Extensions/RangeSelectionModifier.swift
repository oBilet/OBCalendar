//
//  RangeSelectionModifier.swift
//  OBCalendar
//
//  Created by Metin Tarık Kiki on 1.09.2025.
//

import SwiftUI
import Foundation

internal extension BaseCalendarDayView {
    
    enum RangeSelectionState {
        
        case lhsOnly
        case rhsOnly
        case bothSelected
        case noSelection
    }
    
    struct RangeSelectionModifier<
        LhsBackground: View,
        RhsBackground: View,
        InRangeBackground: View
    >: ViewModifier {
        
        @Binding var lhsDate: Date?
        @Binding var rhsDate: Date?
        
        private let viewModel: CalendarModel.DayViewModel
        private let lhsBaseForegroundColor: Color
        private let lhsSelectionForegroundColor: Color
        private let lhsSelectionBackground: LhsBackground
        private let rhsBaseForegroundColor: Color
        private let rhsSelectionForegroundColor: Color
        private let rhsSelectionBackground: RhsBackground
        private let inRangeForegroundColor: Color
        private let inRangeBackground: InRangeBackground
        
        init(
            lhsDate: Binding<Date?>,
            rhsDate: Binding<Date?>,
            viewModel: CalendarModel.DayViewModel,
            lhsBaseForegroundColor: Color,
            lhsSelectionForegroundColor: Color,
            lhsSelectionBackground: LhsBackground,
            rhsBaseForegroundColor: Color,
            rhsSelectionForegroundColor: Color,
            rhsSelectionBackground: RhsBackground,
            inRangeForegroundColor: Color,
            inRangeBackground: InRangeBackground
        ) {
            self._lhsDate = lhsDate
            self._rhsDate = rhsDate
            self.viewModel = viewModel
            self.lhsBaseForegroundColor = lhsBaseForegroundColor
            self.lhsSelectionForegroundColor = lhsSelectionForegroundColor
            self.lhsSelectionBackground = lhsSelectionBackground
            self.rhsBaseForegroundColor = rhsBaseForegroundColor
            self.rhsSelectionForegroundColor = rhsSelectionForegroundColor
            self.rhsSelectionBackground = rhsSelectionBackground
            self.inRangeForegroundColor = inRangeForegroundColor
            self.inRangeBackground = inRangeBackground
        }
        
        private var selectionState: RangeSelectionState {
            if lhsDate == nil,
               rhsDate == nil {
                .noSelection
            } else if lhsDate != nil,
                      rhsDate == nil {
                .lhsOnly
            } else if lhsDate == nil,
                      rhsDate != nil {
                .rhsOnly
            } else {
                .bothSelected
            }
        }
        
        func body(content: Content) -> some View {
            let coloredContent = colored(content: content)
            tappable(content: coloredContent)
        }
        
        @ViewBuilder
        private func tappable<Content: View>(content: Content) -> some View {
            content
                .onTapGesture {
                    contentTapAction()
                }
        }
        
        @ViewBuilder
        private func colored<Content: View>(content: Content) -> some View {
            let selectionState = selectionState
            
            switch selectionState {
            case .lhsOnly:
                lhsOnlyCase(content: content)
            case .rhsOnly:
                rhsOnlyCase(content: content)
            case .bothSelected:
                bothRangeCase(content: content)
            case .noSelection:
                content
            }
        }
        
        @ViewBuilder
        private func lhsOnlyCase<Content: View>(content: Content) -> some View {
            if viewModel.isEqualDay(with: lhsDate) {
                content
                    .foregroundColor(lhsSelectionForegroundColor)
                    .background(lhsSelectionBackground)
            } else {
                content
            }
        }
        
        @ViewBuilder
        private func bothSelectedLhs<Content: View>(content: Content) -> some View {
            content
                .foregroundColor(lhsSelectionForegroundColor)
                .background(
                    ZStack {
                        HStack {
                            Color.clear
                                .frame(maxWidth: .infinity)
                            inRangeBackground
                                .frame(maxWidth: .infinity)
                        }
                        lhsSelectionBackground
                    }
                )
        }
        
        @ViewBuilder
        private func rhsOnlyCase<Content: View>(content: Content) -> some View {
            if viewModel.isEqualDay(with: rhsDate) {
                content
                    .foregroundColor(rhsSelectionForegroundColor)
                    .background(rhsSelectionBackground)
            } else {
                content
            }
        }
        
        @ViewBuilder
        private func bothSelectedRhs<Content: View>(content: Content) -> some View {
            content
                .foregroundColor(rhsSelectionForegroundColor)
                .background(
                    ZStack {
                        HStack {
                            inRangeBackground
                                .frame(maxWidth: .infinity)
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                        rhsSelectionBackground
                    }
                )
        }
        
        @ViewBuilder
        private func bothRangeCase<Content: View>(content: Content) -> some View {
            
            let dateComparisonResult = viewModel.isBetweenDates(lhsDate: lhsDate, rhsDate: rhsDate)
            
            switch dateComparisonResult {
            case .equalToLhs:
                bothSelectedLhs(content: content)
            case .equalToRhs:
                bothSelectedRhs(content: content)
            case .insideRange:
                content
                    .foregroundColor(inRangeForegroundColor)
                    .background(inRangeBackground)
            default:
                content
            }
        }
        
        private func contentTapAction() {
            let oldSelectionState = selectionState
            let targetDate = viewModel.day.date
            
            switch oldSelectionState {
            case .lhsOnly:
                switch viewModel.compareDay(to: lhsDate) {
                case .orderedDescending:
                    rhsDate = targetDate
                default:
                    lhsDate = targetDate
                }
                
            case .rhsOnly:
                switch viewModel.compareDay(to: rhsDate) {
                case .orderedAscending:
                    lhsDate = targetDate
                default:
                    rhsDate = targetDate
                }
            case .bothSelected:
                rhsDate = nil
                lhsDate = targetDate
            case .noSelection:
                lhsDate = targetDate
            }
        }
    }
}

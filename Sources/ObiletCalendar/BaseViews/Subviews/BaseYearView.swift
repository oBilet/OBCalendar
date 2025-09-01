//
//  BaseYearView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public protocol BaseCalendarYearViewProtocol<MonthContent>: View {
    
    associatedtype MonthContent: View
    
    init(viewModel: CalendarModel.YearViewModel, monthsView: MonthContent)
}

public struct BaseCalendarYearView<MonthContent: View>: BaseCalendarYearViewProtocol {
    
    let viewModel: CalendarModel.YearViewModel
    let monthsView: MonthContent
    
    public init(
        viewModel: CalendarModel.YearViewModel,
        monthsView: MonthContent
    ) {
        self.viewModel = viewModel
        self.monthsView = monthsView
    }
    
    public var body: some View {
        monthsView
            .id("\(viewModel.year)")
    }
}

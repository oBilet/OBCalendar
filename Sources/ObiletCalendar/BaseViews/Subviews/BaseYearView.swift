//
//  BaseYearView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public protocol BaseCalendarYearViewProtocol<MonthContent>: View {
    
    associatedtype MonthContent: View
    
    init(model: CalendarModel.Year, monthsView: MonthContent)
}

public struct BaseCalendarYearView<MonthContent: View>: BaseCalendarYearViewProtocol {
    
    let model: CalendarModel.Year
    let monthsView: MonthContent
    
    public init(
        model: CalendarModel.Year,
        monthsView: MonthContent
    ) {
        self.model = model
        self.monthsView = monthsView
    }
    
    public var body: some View {
        monthsView
            .id("\(model.year)")
    }
}

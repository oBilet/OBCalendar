//
//  BaseYearView.swift
//
//
//  Created by Metin Tarık Kiki on 31.10.2024.
//

import SwiftUI

public struct BaseCalendarYearView<MonthContent: View>: View {
    
    let model: CalendarModel.Year
    let monthsView: MonthContent
    
    public var body: some View {
        monthsView
            .id("\(model.year)")
    }
}

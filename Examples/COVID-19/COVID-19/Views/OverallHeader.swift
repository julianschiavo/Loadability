//
//  OverallHeader.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import Loadability
import SwiftUI

struct OverallHeader: View, LoadableView {
    
    @StateObject var loader = OverallLoader()
    
    var body: some View {
        loaderView
    }
    
    func body(with statistic: Statistic) -> some View {
        StatisticView(statistic: statistic)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    func placeholder() -> some View {
        ProgressView("Loading Overall Data...")
    }
}

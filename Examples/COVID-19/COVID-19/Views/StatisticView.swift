//
//  StatisticView.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import SwiftUI

struct StatisticView: View {
    
    let statistic: Statistic
    
    private let formatter = NumberFormatter()
    
    init(statistic: Statistic) {
        self.statistic = statistic
        formatter.numberStyle = .decimal
    }
    
    var body: some View {
        VStack(spacing: 10) {
            label(title: "Cases", count: statistic.caseCount, systemImage: "waveform.path.ecg", color: .red)
            label(title: "Deaths", count: statistic.deathCount, systemImage: "person.fill.xmark", color: Color(.secondarySystemFill))
        }
        .padding()
    }
    
    private func label(title: String, count: Int, systemImage: String, color: Color) -> some View {
        HStack {
            Label {
                VStack(alignment: .leading) {
                    Text(formatter.string(from: count as NSNumber) ?? "")
                        .font(Font.title3.monospacedDigit().weight(.heavy))
                    Text(title)
                        .font(.headline)
                }
            } icon: {
                Image(systemName: systemImage)
                    .font(Font.title2.weight(.heavy))
            }
            Spacer()
        }
        .foregroundColor(.primary)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(10)
    }
}

//
//  ContentView.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import SwiftUI

struct Base: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overall")) {
                    OverallHeader()
                }
                Section(header: Text("States")) {
                    StateList()
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Loadability COVID-19")
        }
    }
}

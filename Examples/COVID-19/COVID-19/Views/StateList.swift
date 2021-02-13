//
//  StateList.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import Loadability
import SwiftUI

struct StateList: View, LoadableView {
    
    @StateObject var loader = StatesLoader()
    
    var body: some View {
        loaderView
    }
    
    func body(with states: [State]) -> some View {
        ForEach(states) { state in
            NavigationLink(state.name, destination: StateInfo(state: state))
        }
    }
    
    func placeholder() -> some View {
        ProgressView("Loading States...")
    }
}

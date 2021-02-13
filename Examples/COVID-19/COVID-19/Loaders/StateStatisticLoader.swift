//
//  StateStatisticLoader.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import Combine
import Foundation
import Loadability

class StateStatisticLoader: SimpleNetworkLoader {
    
    typealias Key = State
    
    @Published var object: Statistic?
    @Published var error: IdentifiableError?
    
    var cancellable: AnyCancellable?
    
    private let baseURL = URL(string: "https://api.covidtracking.com/v1/states")!
    
    required init() {
        
    }
    
    func createRequest(for state: State) -> URLRequest {
        let url = baseURL
            .appendingPathComponent(state.id.lowercased())
            .appendingPathComponent("current.json")
        return URLRequest(url: url)
    }
}

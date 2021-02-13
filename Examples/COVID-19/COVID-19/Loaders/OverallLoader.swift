//
//  OverallLoader.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import Combine
import Foundation
import Loadability

class OverallLoader: SimpleNetworkLoader {
    typealias Key = GenericKey
    
    @Published var object: Statistic?
    @Published var error: IdentifiableError?
    
    var cancellable: AnyCancellable?
    
    private let decoder = JSONDecoder()
    private let url = URL(string: "https://api.covidtracking.com/v1/us/current.json")!
    
    required init() {
        
    }
    
    func createRequest(for key: GenericKey) -> URLRequest {
        URLRequest(url: url)
    }
    
    func decode(_ data: Data, key: GenericKey) throws -> Object {
        let statistics = try decoder.decode([Statistic].self, from: data)
        guard let statistic = statistics.first else {
            throw NSError(domain: "App", code: 0, userInfo: nil)
        }
        return statistic
    }
    
}

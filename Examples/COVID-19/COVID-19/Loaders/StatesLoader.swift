//
//  StatesLoader.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import Combine
import Foundation
import Loadability

struct StatesCache: SharedSerializableCache {
    typealias Key = GenericKey
    typealias Value = [State]
    static let shared = SerializableCache<GenericKey, [State]>.load(name: "States")
}

class StatesLoader: CachedLoader {
    typealias Key = GenericKey
    
    @Published var object: [State]?
    @Published var error: IdentifiableError?
    
    var cache = StatesCache.self
    var cancellable: AnyCancellable?
    
    private let decoder = JSONDecoder()
    private let url = URL(string: "https://api.covidtracking.com/v1/states/info.json")!
    
    required init() {
        
    }
    
    func createRequest(for key: GenericKey) -> URLRequest {
        URLRequest(url: url)
    }
    
    func createPublisher(key: GenericKey) -> AnyPublisher<[State], Error>? {
        let request = createRequest(for: key)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .retry(3)
            .tryMap { data, response in
                try self.decode(data, key: key)
            }
            .eraseToAnyPublisher()
    }
    
    private func decode(_ data: Data, key: Key) throws -> Object {
        try decoder.decode(Object.self, from: data)
    }
    
}

//
//  State.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import Foundation

struct State: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "state"
        case name
    }
}

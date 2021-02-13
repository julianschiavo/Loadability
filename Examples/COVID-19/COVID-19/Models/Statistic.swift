//
//  Statistic.swift
//  COVID-19
//
//  Created by Julian Schiavo on 13/2/2021.
//

import Foundation

struct Statistic: Codable {
    let caseCount: Int
    let deathCount: Int
    
    enum CodingKeys: String, CodingKey {
        case caseCount = "positive"
        case deathCount = "death"
    }
}

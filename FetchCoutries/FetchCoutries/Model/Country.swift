//
//  Country.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import Foundation
import CoreLocation

struct Country: Codable, Identifiable, Equatable {
    var id: String { alpha3Code ?? name }
    
    let name: String
    let alpha2Code: String?
    let alpha3Code: String?
    let capital: String?
    let region: String?
    let subregion: String?
    let population: Int64?
    let latlng: [Double]?
    let currencies: [Currency]?
    let flag: String?
    
    struct Currency: Codable, Equatable {
        let code: String?
        let name: String?
        let symbol: String?
    }
}


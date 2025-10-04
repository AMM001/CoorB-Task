//
//  CountryRepository.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import Foundation

protocol CountryRepositoryType {
    func loadCachedCountries() -> [Country]
    func saveCachedCountries(_ list: [Country])
}

final class CountryRepository: CountryRepositoryType {
    private let key = "SelectedCountries_v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func loadCachedCountries() -> [Country] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? decoder.decode([Country].self, from: data)) ?? []
    }
    
    func saveCachedCountries(_ list: [Country]) {
        guard let data = try? encoder.encode(list) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

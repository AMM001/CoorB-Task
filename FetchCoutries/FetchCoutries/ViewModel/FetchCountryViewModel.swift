//
//  FetchCountryViewModel.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class FetchCountryViewModel: ObservableObject {
    @Published private(set) var allCountries: [Country] = []
    @Published var selectedCountries: [Country] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let network: NetworkServiceType
    private let repository: CountryRepositoryType
    private let locationManager = LocationManager()
    
    private let maxSelected = 5
    
    init(network: NetworkServiceType = NetworkService(),
         repository: CountryRepositoryType = CountryRepository()) {
        self.network = network
        self.repository = repository
        loadCached()
        
        // observe location
        Task { await subscribeLocation() }
    }
    
    // MARK: - Fetch Countries
    func fetchCountries() async {
        isLoading = true
        do {
            let list = try await network.fetchCountries()
            allCountries = list.sorted { $0.name < $1.name }
            isLoading = false
            
            // If no cached countries, auto add from location
            if selectedCountries.isEmpty {
                await requestLocationAndAutoAdd()
            }
        } catch {
            isLoading = false
            errorMessage = "\(error)"
        }
    }
    
    // MARK: - Selection
    func addCountry(_ country: Country) {
        guard !selectedCountries.contains(country),
              selectedCountries.count < maxSelected else { return }
        selectedCountries.append(country)
        repository.saveCachedCountries(selectedCountries)
    }
    
    func removeCountry(_ country: Country) {
        selectedCountries.removeAll { $0 == country }
        repository.saveCachedCountries(selectedCountries)
    }
    
    // MARK: - Search
    var filteredCountries: [Country] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        return query.isEmpty ? allCountries : allCountries.filter {
            $0.name.lowercased().contains(query)
        }
    }
    
    // MARK: - Cache
    private func loadCached() {
        selectedCountries = repository.loadCachedCountries()
    }
    
    // MARK: - Location
    private func subscribeLocation() async {
        for await location in locationManager.locations {
            handleLocation(location)
        }
        
        for await status in locationManager.$authorizationStatus.values {
            switch status {
            case .denied, .restricted:
                addDefaultCountryIfNeeded()
            case .notDetermined:
                await requestLocationAndAutoAdd()
            case .authorizedWhenInUse, .authorizedAlways:
                await requestLocationAndAutoAdd()
            default:
                break
            }
        }

    }
    
    private func requestLocationAndAutoAdd() async {
        if let location = await locationManager.requestLocationOnce() {
            handleLocation(location)
        } else {
            addDefaultCountryIfNeeded()
        }
    }
    
    private func handleLocation(_ location: CLLocation) {
        guard selectedCountries.isEmpty, !allCountries.isEmpty else { return }
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        let match = allCountries.min(by: { lhs, rhs in
            let lhsDist = distance(lhs.latlng, lat: lat, lon: lon)
            let rhsDist = distance(rhs.latlng, lat: lat, lon: lon)
            return lhsDist < rhsDist
        })
        
        if let country = match {
            addCountry(country)
        } else {
            addDefaultCountryIfNeeded()
        }
    }
    
    private func distance(_ latlng: [Double]?, lat: Double, lon: Double) -> Double {
        guard let coords = latlng, coords.count == 2 else { return Double.greatestFiniteMagnitude }
        let dlat = coords[0] - lat
        let dlon = coords[1] - lon
        return dlat * dlat + dlon * dlon
    }
    
    private func addDefaultCountryIfNeeded() {
        guard selectedCountries.isEmpty else { return }
        if let egypt = allCountries.first(where: { $0.name.lowercased().contains("egypt") }) {
            addCountry(egypt)
        } else if let first = allCountries.first {
            addCountry(first)
        }
    }
}



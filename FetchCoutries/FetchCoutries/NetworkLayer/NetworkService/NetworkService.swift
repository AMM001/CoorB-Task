//
//  NetworkService.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case requestFailed(Error)
    case invalidData
    case decodingFailed(Error)
}

protocol NetworkServiceType {
    func fetchCountries() async throws -> [Country]
}

final class NetworkService: NetworkServiceType {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchCountries() async throws -> [Country] {
        guard let url = URL(string: "https://restcountries.com/v2/all?fields=name,capital,currencies,alpha2Code,alpha3Code,latlng,flag") else {
            throw NetworkError.badURL
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            
            do {
                let decoder = JSONDecoder()
                let countries = try decoder.decode([Country].self, from: data)
                return countries
            } catch {
                throw NetworkError.decodingFailed(error)
            }
            
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}


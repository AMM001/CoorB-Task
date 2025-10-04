//
//  CountryDetailView.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import SwiftUI

struct CountryDetailView: View {
    let country: Country
    
    var body: some View {
        VStack(spacing: 16) {
            if let flag = country.flag, let url = URL(string: flag) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 100)
                } placeholder: {
                    ProgressView()
                }
            }
            
            Text(country.name)
                .font(.largeTitle)
                .bold()
            
            if let capital = country.capital {
                Text("Capital: \(capital)")
                    .font(.title3)
            }
            
            if let currencies = country.currencies {
                ForEach(currencies, id: \.code) { currency in
                    Text("Currency: \(currency.name ?? "") (\(currency.code ?? "")) \(currency.symbol ?? "")")
                        .font(.subheadline)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(country.name)
    }
}

#Preview {
    CountryDetailView(country: Country(
        name: "Egypt",
        alpha2Code: "EG",
        alpha3Code: "EGY",
        capital: "Cairo",
        region: "Africa",
        subregion: "Northern Africa",
        population: 104124440,
        latlng: [26.0, 30.0],
        currencies: [
            Country.Currency(code: "EGP", name: "Egyptian Pound", symbol: "£")
        ],
        flag: "https://flagcdn.com/eg.svg"
    ))
}



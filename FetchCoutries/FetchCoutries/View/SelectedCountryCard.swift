//
//  SelectedCountryCard.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import SwiftUI

struct SelectedCountryCard: View {
    let country: Country
    let onRemove: () -> Void
    var body: some View {
        VStack {
            Text(country.name).bold()
            Text(country.capital ?? "-")
            Button(action: onRemove) { Text("Remove").font(.caption) }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.horizontal, 4)
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            if !text.isEmpty {
                Button("Clear") { text = "" }
            }
        }
    }
}

struct AddCountrySheet: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var vm: FetchCountryViewModel
    @State private var query: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $query, placeholder: "Search")
                    .padding()
                List(vm.allCountries.filter {
                    query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                        true : $0.name.lowercased().contains(query.lowercased())
                }) { country in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(country.name)
                            Text(country.capital ?? "-").font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            vm.addCountry(country)
                        }) {
                            Text("Add")
                        }.disabled(vm.selectedCountries.contains(country) || vm.selectedCountries.count >= 5)
                    }
                }
            }
            .navigationTitle("Add country")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { presentation.wrappedValue.dismiss() }
                }
            }
        }
    }
}

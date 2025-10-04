//
//  ContentView.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm = FetchCountryViewModel()
    @State private var showAddSheet = false
    @State private var selectedCountry: Country?
    
    var body: some View {
        NavigationView {
            VStack {
                // Selected countries section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(vm.selectedCountries) { country in
                            SelectedCountryCard(country: country, onRemove: {
                                vm.removeCountry(country)
                            })
                            .padding(.vertical, 6)
                        }
                        // Add slot
                        if vm.selectedCountries.count < 5 {
                            Button(action: { showAddSheet = true }) {
                                VStack {
                                    Image(systemName: "plus.circle")
                                        .font(.largeTitle)
                                    Text("Add")
                                }
                                .padding()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                // Search and list
                SearchBar(text: $vm.searchText, placeholder: "Search country")
                    .padding(.horizontal)
                
                List(vm.filteredCountries) { country in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(country.name).font(.headline)
                            Text(country.capital ?? "—")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { vm.addCountry(country) }) {
                            Text(vm.selectedCountries.contains(country) ? "Added" : "Add")
                        }
                        .disabled(vm.selectedCountries.contains(country) || vm.selectedCountries.count >= 5)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Open detail
                        selectedCountry = country
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Countries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await vm.fetchCountries()
                        }
                    }
                }
            }
            .task {
                await vm.fetchCountries()
            }
            .sheet(isPresented: $showAddSheet) {
                AddCountrySheet(vm: vm)
            }
            .sheet(item: $selectedCountry) { country in
                CountryDetailView(country: country)
            }
        }
    }
}

#Preview {
    MainView()
}



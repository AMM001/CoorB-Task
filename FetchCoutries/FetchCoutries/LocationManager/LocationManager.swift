//
//  LocationManager.swift
//  FetchCoutries
//
//  Created by vodafone on 04/10/2025.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let subject = PassthroughSubject<CLLocation, Never>()
    
    @Published var currentCountryCode: String? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.authorizationStatus = manager.authorizationStatus
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func requestLocationOnce() async -> CLLocation? {
        await withCheckedContinuation { continuation in
            manager.requestLocation()
            
            _ = subject.sink { location in
                continuation.resume(returning: location)
            }
            
            // Clean up after returning once
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                continuation.resume(returning: nil)
            }
        }
    }
    
    // MARK: - AsyncSequence for locations
    var locations: AsyncStream<CLLocation> {
        AsyncStream { continuation in
            let cancellable = subject.sink { location in
                continuation.yield(location)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
    
    // MARK: - Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        subject.send(location)
        
        let geo = CLGeocoder()
        geo.reverseGeocodeLocation(location) { placemarks, _ in
            if let countryCode = placemarks?.first?.isoCountryCode {
                DispatchQueue.main.async {
                    self.currentCountryCode = countryCode
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}



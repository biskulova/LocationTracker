// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreLocation
import Combine

public class LocationTracker: NSObject {
    
    private let api = API()
    private let locationManager = CLLocationManager()
    private var cancellable: Cancellable?
    private var continuation: CheckedContinuation<LocationData, Error>?
    
    // Public
    public static let shared = LocationTracker()
    public var configuration = Configuration() {
        didSet {
            // TODO: reset session & invalidate previous
        }
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        cancellable = nil
        continuation = nil
    }
    
    public func initialize() async {
        do {
            try await api.sendRequest(endpointType: .auth)
            setupLocationManager()
            if CLLocationManager.locationServicesEnabled() {
                cancellable = Timer.publish(every: configuration.trackingPeriod, on: .main, in: .default)
                    .autoconnect()
                    .sink { [weak self] _ in
                        self?.scheduleSendingLocation()
                    }
            }
        } catch TrackerError.authFailed {
            print("auth error occured")
        } catch {
            print("error in 'initialize' occured: \(error)")
        }
    }

    public func sendCurrentLocation() async {
        if api.isAuthorized {
            do {
                let locationData = try await getCurrentLocation()
                
                try await api.sendRequest(endpointType: .location, locationData: locationData)
            } catch {
                print("error in 'sendCurrentLocation' occured: \(error)")
            }
        } else {
            do {
                try await api.sendRequest(endpointType: .auth)
            } catch {
                print("error in auth request in 'sendCurrentLocation' occured: \(error)")
            }
        }
    }
    
    private func scheduleSendingLocation() {
        Task {
            await sendCurrentLocation()
        }
    }
    
    private func getCurrentLocation() async throws -> LocationData {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LocationData, Error>) in
            self.continuation = continuation
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestLocation()
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
}

enum LocationManagerError: Error {
    case unknown
}

extension LocationTracker: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let locationData = LocationData(
                longitude: "\(location.coordinate.longitude)",
                latitude: "\(location.coordinate.latitude)"
            )
            self.continuation?.resume(with: .success(locationData))
        } else {
            self.continuation?.resume(with: .failure(LocationManagerError.unknown))
        }
        self.continuation = nil
        print("Updated location: \(String(describing: locations.last))")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.continuation?.resume(with: .failure(error))
        self.continuation = nil

        print("Location update error: \(error)")
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        default:
            break
        }
    }
}

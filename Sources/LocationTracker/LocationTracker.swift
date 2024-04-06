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
    private var canSendLocation: Bool {
        api.isAuthorized && CLLocationManager.locationServicesEnabled()
    }
    
    // Public
    public static let shared = LocationTracker()
    public var configuration = Configuration() {
        didSet {
            cancellable = nil
            scheduleLocationUpdates()
        }
    }
    
    public func initialize() async {
        setupLocationManager()
        
        if !canSendLocation {
            await api.refreshToken()
        }
        scheduleLocationUpdates()
    }
    
    public func sendCurrentLocation() async {
        do {
            let locationData = try await getCurrentLocation()
            
            print("sending location from \(#function)")
            await api.sendLocation(locationData)
        } catch {
            print("Error occured while receiving location update: \(error)")
        }
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        cancellable = nil
        continuation = nil
        print(#function)
    }
}

extension LocationTracker {
    fileprivate func scheduleLocationUpdates() {
        cancellable = Timer.publish(every: configuration.trackingPeriod, 
                                    on: .main,
                                    in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.provideLocation()
            }
    }
    
    fileprivate func provideLocation() {
        Task {
            await sendCurrentLocation()
        }
        print(#function)
    }
    
    fileprivate func getCurrentLocation() async throws -> LocationData {
        return try await withCheckedThrowingContinuation { 
            (continuation: CheckedContinuation<LocationData, Error>) in
            self.continuation = continuation
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestLocation()
            }
            print(#function)
        }
    }
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        
#if os(iOS)
        if CLLocationManager.locationServicesEnabled() &&
            locationManager.authorizationStatus != .authorizedWhenInUse {
                locationManager.requestWhenInUseAuthorization()
            }
#elseif os(macOS)
        if CLLocationManager.locationServicesEnabled() &&
            locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
#endif
        print(#function)
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

        print("Location update did failed error: \(error)")
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

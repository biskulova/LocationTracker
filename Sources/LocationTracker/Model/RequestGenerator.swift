//
//  RequestGenerator.swift
//
//
//  Created by Oleksandra Biskulova on 04.04.2024.
//

import Foundation

struct RequestGenerator {
    static func basicRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    static func authRequest(url: URL) -> URLRequest {
        var request = basicRequest(url)
        request.setValue("Bearer \(Constants.ConfigValues.token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    static func refreshRequest(url: URL, refreshToken: String) -> URLRequest {
        var request = basicRequest(url)
        request.setValue(refreshToken, forHTTPHeaderField: "Authorization")
        return request
    }

    static func locationRequest(url: URL, token: String, location: LocationData) -> URLRequest {
        var request = basicRequest(url)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let data = [
            Constants.longitude : location.longitude,
            Constants.latitude : location.latitude
        ]
        
        request.httpBody = try? JSONEncoder().encode(data)
        assert(request.httpBody != nil, "Failed to create location data for URLRequest")

        return request
    }
    
    static func requestWith(url: URL, endpointType: EndpointType, token: Token?, locationData: LocationData?) -> URLRequest? {
        switch endpointType {
        case .auth:
            return RequestGenerator.authRequest(url: url)
        case .refreshSession:
            if let refreshToken = token?.refreshToken {
                return RequestGenerator.refreshRequest(url: url, refreshToken: refreshToken)
            }
        case .location:
            if let authToken = token?.accessToken, let locationData = locationData {
                return RequestGenerator.locationRequest(url: url, token: authToken, location: locationData)
            }
        }
        return nil
    }
}

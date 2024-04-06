//
//  RequestGenerator.swift
//
//
//  Created by Oleksandra Biskulova on 04.04.2024.
//

import Foundation

struct RequestGenerator {
    static func headers(token: String, isBearer: Bool = false) -> [String : String] {
        let authToken = isBearer ? "Bearer \(token)" : token
        
        return ["application/json": "Content-Type",
                "Authorization": authToken]
    }
    
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
        let eventData = try? JSONEncoder().encode(data)

        print("Events Data dict for URLRequest has length: \(String(describing: eventData?.count))")
        assert(eventData != nil, "Failed to create Events Data for URLRequest")

        return request
    }
}


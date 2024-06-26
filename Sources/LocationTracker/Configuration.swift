//
//  Configuration.swift
//
//
//  Created by Oleksandra Biskulova on 04.04.2024.
//

import Foundation

enum EndpointType: String {
    case auth = "/auth" //: "POST to get a new access and refresh token. Requires header Authorization: Bearer <DUMMY_API_KEY>",
    case refreshSession = "/auth/refresh" //: "POST to get a new access token from a refresh token. Requires header Authorization: <refreshToken>",
    case location = "/location"//: "POST to update a location. Requires header Authorization: <accessToken> and a body with longitude and latitude."
}

enum Constants {
    enum ConfigKeys {
         static let endpoint = "httpEndpoint"
         static let token = "token"
     }

     // config default values
     enum ConfigValues {
         static let endpoint = "https://dummy-api-mobile.api.sandbox.bird.one"
         static let token = "xdk8ih3kvw2c66isndihzke5"
     }
    
    static let longitude = "longitude";
    static let latitude = "latitude";
}

public struct Configuration {
    var endpoint: String = Constants.ConfigValues.endpoint
    var trackingPeriod: TimeInterval = 60 // 1 min

    private let token: String = Constants.ConfigValues.token
    private let sessionId = UUID().uuidString
        
    public init(endpoint: String, trackingPeriod: TimeInterval) {
        self.endpoint = endpoint
        self.trackingPeriod = trackingPeriod
    }
}


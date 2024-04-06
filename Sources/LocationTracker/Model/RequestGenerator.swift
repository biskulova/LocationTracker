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

public struct Token: Codable {
    public var accessToken: String
    public var refreshToken: String?
    public var expirationDate: Date
    
    public init(
        accessToken: String,
        refreshToken: String? = nil,
        expirationDate: Date) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expirationDate = expirationDate
        }
}

struct SomeError: Error {
    var message: String?
}

struct AuthResponse: Decodable {
    var token: Token
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case expiresAt = "expiresAt" //"2024-04-04T10:53:23.345Z"
        case refreshToken = "refreshToken"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let accessToken = try container.decode(String.self, forKey: .accessToken)
        let refreshToken = try container.decode(String.self, forKey: .refreshToken)
        let expirationDate = try container.decode(String.self, forKey: .expiresAt)
        
        let expiresIn: Int
        if let expiresInString = try? container.decode(String.self, forKey: .expiresAt) {
            guard let value = Int(expiresInString) else {
                throw SomeError(message: "Expires in is not a valid integer.")
            }
            expiresIn = value
        } else {
            expiresIn = try container.decode(Int.self, forKey: .expiresAt)
        }

        let expirationDate2 = Date(timeIntervalSinceNow: Double(expiresIn))
        token = Token(accessToken: accessToken, refreshToken: refreshToken, expirationDate: expirationDate2)
    }
}


struct RefreshResponse: Decodable {
}

struct LocationResponse: Decodable {
}

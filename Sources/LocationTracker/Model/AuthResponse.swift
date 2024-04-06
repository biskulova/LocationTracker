//
//  AuthResponse.swift
//
//
//  Created by Oleksandra Biskulova on 06.04.2024.
//

import Foundation

struct AuthResponse: Decodable {
    var token: Token
    
    private enum CodingKeys: String, CodingKey {
        case accessToken
        case expiresAt //"2024-04-04T10:53:23.345Z"
        case refreshToken
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let accessToken = try container.decode(String.self, forKey: .accessToken)
        let refreshToken = try container.decode(String.self, forKey: .refreshToken)
        let expirationDate = try container.decode(String.self, forKey: .expiresAt)
        
        let expiresIn: Int
        if let expiresInString = try? container.decode(String.self, forKey: .expiresAt) {
            guard let value = Int(expiresInString) else {
                throw ResponseError.parsingError
            }
            expiresIn = value
        } else {
            expiresIn = try container.decode(Int.self, forKey: .expiresAt)
        }

        let expirationDate2 = Date(timeIntervalSinceNow: Double(expiresIn))
        token = Token(accessToken: accessToken, refreshToken: refreshToken, expirationDate: expirationDate2)
    }
}

struct LocationResponse: Decodable {
}

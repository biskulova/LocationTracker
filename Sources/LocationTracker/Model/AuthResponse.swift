//
//  AuthResponse.swift
//
//
//  Created by Oleksandra Biskulova on 06.04.2024.
//

import Foundation

struct AuthResponse: Decodable {
    let accessToken: String
    let expiresAt: Date
    let refreshToken: String

    let token: Token
    
    private enum CodingKeys: String, CodingKey {
        case accessToken
        case expiresAt
        case refreshToken
    }
        
    private let dateTimeFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
        let expirationDate = try container.decode(String.self, forKey: .expiresAt)
        self.expiresAt = dateTimeFormatter.date(from: expirationDate) ?? Date()

        self.token = Token(accessToken: accessToken, refreshToken: refreshToken, expirationDate: expiresAt)
    }
}

struct LocationResponse: Decodable {
}

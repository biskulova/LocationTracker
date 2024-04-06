//
//  Token.swift
//  
//
//  Created by Oleksandra Biskulova on 06.04.2024.
//

import Foundation

struct Token: Codable {
    var accessToken: String
    var refreshToken: String
    var expirationDate: Date
    
    init(
        accessToken: String,
        refreshToken: String,
        expirationDate: Date) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expirationDate = expirationDate
        }
}

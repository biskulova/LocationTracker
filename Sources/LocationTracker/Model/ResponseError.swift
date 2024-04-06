//
//  ResponseError.swift
//  
//
//  Created by Oleksandra Biskulova on 06.04.2024.
//

import Foundation

enum ResponseError: Error {
    case invalidRequest
    case invalidServerResponse
    case invalidRefreshToken
    case invalidAccessToken
    case parsingError
}

public enum TrackerError: Error {
    case authFailed
    case locationServiceForbidden
    case refreshFailed
}

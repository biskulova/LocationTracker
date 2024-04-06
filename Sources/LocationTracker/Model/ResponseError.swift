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
    case serverError(Int)
}

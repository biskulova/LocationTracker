//
//  LocationResponse.swift
//
//
//  Created by Oleksandra Biskulova on 06.04.2024.
//

import Foundation

struct LocationResponse: Decodable {
    let result: Bool
    
    private enum CodingKeys: String, CodingKey {
        case result
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.result = try container.decode(Bool.self, forKey: .result)
    }
}

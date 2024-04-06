//
//  RequestGeneratorTests.swift
//
//
//  Created by Alexandra Biskulova on 06.04.2024.
//

import XCTest
@testable import LocationTracker

final class RequestGeneratorTests: XCTestCase {
    
    let urlString = "https://developer.apple.com/documentation/xctest"

    func testBasicRequest_createdCorrectly() {
        let url = URL(string: urlString)!
        
        let sut = RequestGenerator.basicRequest(url)
        
        XCTAssertNotNil(sut.httpMethod)
        XCTAssertEqual(sut.httpMethod, "POST")
        
        XCTAssertEqual(sut.url, url)
        XCTAssertNil(sut.httpBody)
        
        XCTAssertEqual(sut.allHTTPHeaderFields?["Content-Type"], "application/json")
    }

    func testAuthRequest_createdCorrectly() {
        let url = URL(string: urlString)!
        
        let sut = RequestGenerator.authRequest(url: url)
        
        XCTAssertNotNil(sut.httpMethod)
        XCTAssertEqual(sut.httpMethod, "POST")

        XCTAssertEqual(sut.url, url)
        XCTAssertNil(sut.httpBody)

        XCTAssertEqual(sut.allHTTPHeaderFields?["Authorization"], "Bearer \(Constants.ConfigValues.token)")
    }
    
    func testRefreshRequest_createdCorrectly() {
        let url = URL(string: urlString)!
        let refreshToken = "22787GH8820ZVdn"
        
        let sut = RequestGenerator.refreshRequest(url: url, refreshToken: refreshToken)
        
        XCTAssertNotNil(sut.httpMethod)
        XCTAssertEqual(sut.httpMethod, "POST")

        XCTAssertEqual(sut.url, url)
        XCTAssertNil(sut.httpBody)

        XCTAssertEqual(sut.allHTTPHeaderFields?["Authorization"], refreshToken)
    }
    
    func testLocationRequest_createdCorrectly() {
        let url = URL(string: urlString)!
        let accessToken = "fg22787GH8820ZVdn"
        let coordinate = "52.66734"
    
        let locData = LocationData(longitude: coordinate, latitude: coordinate)
        
        let sut = RequestGenerator.locationRequest(url: url, token: accessToken, location: locData)
        
        XCTAssertNotNil(sut.httpMethod)
        XCTAssertEqual(sut.httpMethod, "POST")

        XCTAssertEqual(sut.url, url)
        XCTAssertNotNil(sut.httpBody)
        
        let decodedData = try? JSONDecoder().decode(LocationData.self, from: sut.httpBody!)
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(decodedData?.latitude, coordinate)
        XCTAssertEqual(decodedData?.longitude, coordinate)

        XCTAssertEqual(sut.allHTTPHeaderFields?["Authorization"], accessToken)
    }
    
    func testRequestForAuthEndpointType_withCorrectValues_createdCorrectly() {
        let url = URL(string: urlString)!
        let endpoint = EndpointType.auth

        let sut = RequestGenerator.requestWith(url: url, endpointType: endpoint, token: nil, locationData: nil)
        
        XCTAssertNotNil(sut)
        
        XCTAssertNotNil(sut!.httpMethod)
        XCTAssertEqual(sut!.httpMethod, "POST")

        XCTAssertEqual(sut!.url, url)
        XCTAssertNil(sut!.httpBody)

        XCTAssertEqual(sut!.allHTTPHeaderFields?["Authorization"], "Bearer \(Constants.ConfigValues.token)")
    }

    func testRequestForRefreshEndpointType_withCorrectValues_createdCorrectly() {
        let url = URL(string: urlString)!
        let endpoint = EndpointType.refreshSession
        let refreshToken = "fg22787GH8820ZVdn"
        let token = Token(accessToken: "fg22787GH8820ZVdn", refreshToken: refreshToken, expirationDate: Date())

        let sut = RequestGenerator.requestWith(url: url, endpointType: endpoint, token: token, locationData: nil)
        
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut!.httpMethod)
        XCTAssertEqual(sut!.httpMethod, "POST")

        XCTAssertEqual(sut!.url, url)
        XCTAssertNil(sut!.httpBody)

        XCTAssertEqual(sut!.allHTTPHeaderFields?["Authorization"], refreshToken)
    }

    func testRequestForRefreshEndpointType_withIncorrectValues_returnNil() {
        let url = URL(string: urlString)!
        let endpoint = EndpointType.refreshSession

        let sut = RequestGenerator.requestWith(url: url, endpointType: endpoint, token: nil, locationData: nil)
        
        XCTAssertNil(sut)
    }

    func testRequestForLocationEndpointType_withCorrectValues_createdCorrectly() {
        let url = URL(string: urlString)!
        let endpoint = EndpointType.location
        let accessToken = "fg22787GH8820ZVdn"
        let coordinate = "52.66734"
        let locData = LocationData(longitude: coordinate, latitude: coordinate)
        let token = Token(accessToken: accessToken, refreshToken: "", expirationDate: Date())

        let sut = RequestGenerator.requestWith(url: url, endpointType: endpoint, token: token, locationData: locData)
        
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut!.httpMethod)
        XCTAssertEqual(sut!.httpMethod, "POST")

        XCTAssertEqual(sut!.url, url)
        XCTAssertNotNil(sut!.httpBody)
        
        let decodedData = try? JSONDecoder().decode(LocationData.self, from: sut!.httpBody!)
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(decodedData?.latitude, coordinate)
        XCTAssertEqual(decodedData?.longitude, coordinate)

        XCTAssertEqual(sut!.allHTTPHeaderFields?["Authorization"], accessToken)
    }

    func testRequestForLocationEndpointType_withIncorrectValues_returnNil() {
        let url = URL(string: urlString)!
        let endpoint = EndpointType.location

        let sut = RequestGenerator.requestWith(url: url, endpointType: endpoint, token: nil, locationData: nil)
        
        XCTAssertNil(sut)
    }
}

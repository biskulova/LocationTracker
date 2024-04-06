//
//  API.swift
//
//
//  Created by Oleksandra Biskulova on 04.04.2024.
//

import Foundation

class API {
    private var token: Token?
    
    public var isAuthorized: Bool {
        if let token = token, token.expirationDate < Date() {
            return true
        }
        return false
    }
    
    public func refreshToken() async {
        if let token = token, token.expirationDate >= Date() {
            await sendRequest(endpointType: .refreshSession)
        } else {
            await sendRequest(endpointType: .auth)
        }
    }
    
    public func sendLocation(_ locationData: LocationData) async {
        if !isAuthorized {
            await refreshToken()
        }
        await sendRequest(endpointType: .location, locationData: locationData)
        print("trying to authentificate from \(#function)")
    }
    
    public func sendRequest(endpointType: EndpointType, locationData: LocationData? = nil) async {
        
        guard let url = URL(string: Constants.ConfigValues.endpoint + endpointType.rawValue) else {
            print("Can't create URL for endpoint:\(Constants.ConfigValues.endpoint)\(endpointType.rawValue) ")
            return
        }
        
        Task {
            guard let request = RequestGenerator.requestWith(url: url, endpointType: endpointType, token: token, locationData: locationData) else {
                throw ResponseError.invalidRequest
            }

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("response = \(String(describing: response))")
                    throw ResponseError.invalidServerResponse
                }
                
                if !(200..<299).contains(httpResponse.statusCode) {
                    throw ResponseError.serverError(httpResponse.statusCode)
                } else {
                    print("response data: \(String(data: data, encoding: .utf8) ?? "")")
                    
                    switch endpointType {
                    case .auth, .refreshSession:
                        let decodedResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        token = decodedResponse.token
                    case .location:
                        _ = try JSONDecoder().decode(LocationResponse.self, from: data)
                    }
                }
            } catch ResponseError.invalidServerResponse {
                print("invalidServerResponse for request: \(request)")
            } catch ResponseError.serverError(let code){
                print("Server responded for request: \(request) with code: \(code)")
            } catch ResponseError.invalidRequest {
                print("Invalid request generated for endpoint: \(endpointType)")
            } catch {
                print("Unexpected error: \(error) executing request: \(request) .")
            }
        }
    }
}

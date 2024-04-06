//
//  API.swift
//
//
//  Created by Oleksandra Biskulova on 04.04.2024.
//

import Foundation

public class API {
    
    // TODO: send requests on specific named queue
    
    private var token: Token?
    
    func sendRequest(endpointType: EndpointType, locationData: LocationData? = nil) async throws {
        
        guard let url = URL(string: Constants.ConfigValues.endpoint + endpointType.rawValue) else { return }

        Task {
            var request: URLRequest?
            switch endpointType {
            case .auth:
                request = RequestGenerator.authRequest(url: url)
            case .refreshSession:
                if let refreshToken = token?.refreshToken {
                    request = RequestGenerator.refreshRequest(url: url, refreshToken: refreshToken)
                } else {
                    // auth again!
                }
            case .location:
                if let authToken = token?.accessToken, let locationData = locationData { // check expiration DATE
                    request = RequestGenerator.locationRequest(url: url, token: authToken, location: locationData)
                }
            }
        
            guard let request = request else {
                return
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }

//                if httpResponse.statusCode == 401 {
//                    try await refreshToken()
//                    await sendRequest(endpointType: endpointType, locationData: locationData, completion: completion)
//                } else {
                
                switch endpointType {
                case .auth:
                    let decodedResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    token = decodedResponse.token
                default:
                    break
                }

            } catch {
//                completion(.failure(error))
            }
        }
    }
      
      // MARK: - Private Methods
      
//      private func refreshToken() async throws {
//          // Make the API call to refresh the token
//          // You can implement your own logic here to refresh the token using a POST request or any other method
//          // Once you receive the new token, update the `refreshToken` property
//          
//          // Simulating a delay and providing a dummy new token
//          refreshToken = "new_refresh_token"
//          
//          // Retry the original failed request
//          try await withCheckedThrowingContinuation { continuation in
//              sendRequest(method: continuation.resume, endpoint: continuation.resume, parameters: continuation.resume, completion: continuation.resume)
//          }
//      }
//  }
}

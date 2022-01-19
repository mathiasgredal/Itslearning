//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  AuthHandler+REST.swift
//  Itslearning

import Foundation
import Alamofire

/// An extension to the AuthHandler class, giving it request capabilities
extension AuthHandler {
    
    /// Make request and retry once in case of 401 unauthorized
    private func GetRequest(url: String, refreshed: Bool = false, completion: @escaping ((data: Data?, error: AFError?))->()) {
        Logging.Log(message: "Making get request: " + url, source: .MainApp)

        manager.request(url).validate().response { response in
            if(response.error != nil || response.response?.statusCode == 401) {
                Logging.Log(message: "Error in get request", source: .MainApp)

                if(refreshed) {
                    Logging.Log(message: "Request failed after reload", source: .MainApp)
                    completion((nil, response.error))
                } else {
                    Logging.Log(message: "Doing auth token reload", source: .MainApp)

                    self.ReloadAuthToken(completion: { success in
                        if(success) {
                            Logging.Log(message: "Successfully reloaded trying request again", source: .MainApp)
                            
                            // We need to rewrite the url
                            guard var urlComponents = URLComponents(string: url) else {
                                return
                            }
                            
                            // Get the queryitems, if they don't exist then we don't need to add a new access token
                            guard var queryItems = urlComponents.queryItems else {
                                self.GetRequest(url: url, refreshed: true, completion: completion)
                                return
                            }
                            
                            // Remove all access tokens from query items
                            queryItems.enumerated().filter({ $0.element.name == "access_token" }).forEach({queryItems.remove(at: $0.offset)})
                            
                            // Add updated access token back
                            queryItems += [URLQueryItem(name: "access_token", value: self.GetAuthToken()?.accessToken)]
                            
                            // Apply the new query items
                            urlComponents.queryItems = queryItems
                            
                            // Generate teh new url
                            guard let newUrl = urlComponents.string else {
                                completion((nil, "Could not update query items".asAFError))
                                return
                            }
                            
                            // Rerun the get request
                            self.GetRequest(url: newUrl, refreshed: true, completion: completion)
                        } else {
                            Logging.Log(message: "Failed to reload", source: .MainApp)
                            completion((nil, response.error))
                        }
                    })
                }
            } else {
                completion((response.data, nil))
            }
        }
    }
        
    /// Make get request with access token and return response or error
    func GetRequest(path: String, queryItems: [String: String] = [:], completion: @escaping ((data: Data?, error: AFError?))->()) {
        // Step 1: Retrieve access token
        guard let accessToken = GetAuthToken()?.accessToken else {
            completion((nil, "Failed to retrieve OAuth access token".asAFError))
            return
        }
        
        // Step 2: Sanitycheck path
        if(!path.hasPrefix("/")) {
            completion((nil, "Invalid URL path given".asAFError))
            return
        }
        
        // Step 3: Construct url
        guard let url = ItslearningAPI.GenerateItslearningURL(path: path, queryItems: queryItems, accessToken: accessToken) else {
            completion((nil, "Could not construct url".asAFError))
            return
        }
        
        // Step 4: Make request
        GetRequest(url: url) { response in
            completion(response)
        }
    }
    
    func GetRequestString(path: String, queryItems: [String: String] = [:], completion: @escaping ((data: String?, error: AFError?))->()) {
        GetRequest(path: path, queryItems: queryItems) { response in
            guard let data = response.data else {
                completion((nil, "Response was nil".asAFError))
                return
            }
            completion((String(decoding: data, as: UTF8.self), response.error))
        }
    }
    
    /// Make an SSO authenticated get request to itslearning and returns string response
    func GetRequestSSO(url: String, completion: @escaping ((data: String?, error: AFError?))->()) {
        GetRequest(path: "/restapi/personal/sso/url/v1", queryItems: ["url": url], type: SSOResponse.self) { response in
            guard let data = response.data else {
                completion((nil, response.error))
                return
            }

            self.GetRequest(url: data.Url) { response in
                guard let data = response.data else {
                    completion((nil, response.error))
                    return
                }
                completion((String(decoding: data, as: UTF8.self), nil))
            }
        }
    }
    
    /// Makes a get request, deserialize it and returns the response with the provided type
    func GetRequest<T: Decodable>(path: String, queryItems: [String: String] = [:], type: T.Type = T.self, completion: @escaping ((data: T?, error: AFError?))->()) {
        GetRequest(path: path, queryItems: queryItems) { response in
            guard let data = response.data else {
                completion((nil, "Response was nil".asAFError))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let decodedData = try jsonDecoder.decode(type.self, from: data)
                completion((decodedData, nil))
            } catch {
                Logging.Log(message: "Failed to decode", source: .AuthHandler)
                completion((nil, "Failed to decode response".asAFError))
            }
        }
    }
}

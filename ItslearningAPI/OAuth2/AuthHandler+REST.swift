//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  AuthHandler+REST.swift
//  Itslearning

import Foundation
import Alamofire

/// An extension to the AuthHandler class, giving it GET request capabilities
extension AuthHandler {
    /// Makes get request and returns string response
    func GetRequest(url: String, completion: @escaping ((data: String?, error: AFError?))->()) {
        AF.request(url, interceptor: OAuth2RetryHandler(authHandler: self), requestModifier: { $0.timeoutInterval = 5 }).validate().responseString(completionHandler: { response in
            switch response.result {
            case .success(let data):
                completion((data, nil))
            case .failure(let error):
                completion((nil, error))
            }
        })
    }
    
    /// Makes an SSO authenticated get request to itslearning and returns string response
    func GetRequestSSO(url: String, completion: @escaping ((data: String?, error: AFError?))->()) {
        GetRequest(url: "https://sdu.itslearning.com/restapi/personal/sso/url/v1?url=\(url)", type: SSOResponse.self) { response in
            guard let data = response.data else {
                completion((nil, response.error))
                return
            }

            self.GetRequest(url: data.Url) { response in
                guard let data = response.data else {
                    completion((nil, response.error))
                    return
                }
                completion((data, nil))
            }
        }
    }
    
    /// Makes a get request, deserialize it and returns the response with the provided type
    func GetRequest<T: Decodable>(url: String, type: T.Type = T.self, completion: @escaping ((data: T?, error: AFError?))->()) {
        AF.request(url, interceptor: OAuth2RetryHandler(authHandler: self), requestModifier: { $0.timeoutInterval = 5 }).validate().responseDecodable(of: type.self) { response in            
            switch response.result {
            case .success(let data):
                completion((data, nil))
            case .failure(let error):
                completion((nil, error))
            }
        }
    }
}

//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  AuthHandler.swift
//  ItslearningAPI

import Foundation
import OAuth2
import Alamofire
import FileProvider

/// The main class for doing SSO Authenticated communication with Itslearning
class AuthHandler: ObservableObject {
    /// Create OAuth2 Code Grant using hard-coded values for Itslearning
    /// NOTE: The client id "10ae9d30-1853-48ff-81cb-47b58a325685", is a value extracted from the itslearning app apk file
    public let oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "10ae9d30-1853-48ff-81cb-47b58a325685",
        "authorize_uri": "https://\(Constants.itslearningBaseDomain)/oauth2/authorize.aspx",
        "token_uri": "https://\(Constants.itslearningBaseDomain)/restapi/oauth2/token",
        "redirect_uris": ["itsl-itslearning://login"],
        "scope": "SCOPE",
        "secret_in_body": false,
        "keychain": false
    ] as OAuth2JSON)
    
    @Published public var loading: Bool = true
    @Published public var isLoggedIn: Bool = false
    
    /// The constructor creates an AuthHandler instance,
    /// and if successful set the member variable isLoggedIn to true and calls the completion handler with the parameter true.
    /// Otherwise it calls it the completion handler with false
    init() {
        Logging.Log(message: "Initialising Auth Handler", source: .AuthHandler)
        
        VerifyAuthToken() { success in
            if(success) {
                Logging.Log(message: "Successfully loaded and verified auth tokens", source: .AuthHandler)
                self.isLoggedIn = true
                self.loading = false
            } else {
                Logging.Log(message: "Could not sign in", source: .AuthHandler)
                self.loading = false
            }
        }
    }
    
    /// Reads the AuthToken from user defaults, returns nil if not found
    func GetAuthToken() -> AuthToken? {
        do {
            if let authTokenData = UserDefaults.sharedContainerDefaults.object(forKey: "authToken") {
                return try JSONDecoder().decode(AuthToken.self, from:  authTokenData as! Data)
            }
        } catch {
            return nil
        }
        return nil
    }
    
    /// Removes the AuthToken from user default and from the current OAuth2 instance
    func LogOut() {
        Logging.Log(message: "Logging out", source: .AuthHandler)
        UserDefaults.sharedContainerDefaults.removeObject(forKey: "authToken")
        oauth2.forgetTokens()
        self.isLoggedIn = false
    }
    
    /// If possible we refresh the AuthToken and save it to user defaults, if the RefreshToken is invalid or there is som other error, we print it
    func ReloadAuthToken(completion: @escaping (Bool)->()) {
        Logging.Log(message: "Reloading auth token", source: .AuthHandler)
        guard let authToken = GetAuthToken() else {
            Logging.Log(message: "Could not find auth tokens in user defaults", source: .AuthHandler)
            completion(false)
            return
        }
        
        oauth2.accessToken = authToken.accessToken
        oauth2.accessTokenExpiry = authToken.accessTokenDate
        oauth2.refreshToken = authToken.refreshToken
        
        oauth2.doRefreshToken(params: ["federated_login_provider_id": "0"]) { keys, error in
            if let unwrappedError = error {
                Logging.Log(message: unwrappedError.description, source: .AuthHandler)
                completion(false)
                return
            }
            
            // No error occured, we can safely store the new tokens
            self.SaveTokens()
            completion(true)
        }
    }
    
    /// Signs in using an embedded safari window, if we are already signed in no window is shown
    /// If this is called from the App Extension, then we throw an error
    func SignIn() throws {
        Logging.Log(message: "Signing in", source: .AuthHandler)
        
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            throw "Cannot sign user in from app extension, please open the app to sign in and reload the app extension"
        }
        
        oauth2.authorizeEmbedded(from: NSString(), params: ["federated_login_provider_id": "0"], callback: { authParameters, error in
            if error == nil && authParameters != nil  {
                Logging.Log(message: "Authentication successful", source: .MainApp)
                self.SaveTokens()
                self.isLoggedIn = true
            }
            else {
                Logging.Log(message: "Error occured: \(error!)", source: .MainApp)
            }
        })
    }
    
    /// Verifies the AuthToken by making a request to Itslearning Rest API
    func VerifyAuthToken(completion: @escaping (Bool)->()) {
        Logging.Log(message: "Verifying auth token", source: .AuthHandler)
        ItslearningAPI.GetCourses(self) { response in
            // TODO: You cannot login if you don't have any courses, perhaps match against another endpoint
            if(response.data.isEmpty) {
                Logging.Log(message: "\(response.error.debugDescription)", source: .AuthHandler)
                Logging.Log(message: "Failed to verify auth token", source: .AuthHandler)
                completion(false)
            } else {
                Logging.Log(message: "Succesfylly verified auth token", source: .AuthHandler)
                completion(true)
            }
        }
        
    }
    
    /// Saves the current tokens to user defaults
    func SaveTokens() {
        if let accessToken = oauth2.accessToken,
           let refreshToken = oauth2.refreshToken,
           let accessTokenDate = oauth2.accessTokenExpiry
        {
            let authToken = AuthToken(accessToken: accessToken, refreshToken: refreshToken, accessTokenDate: accessTokenDate);
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(authToken)
                UserDefaults.sharedContainerDefaults.set(data, forKey: "authToken")
                Logging.Log(message: "Saved OAuth2 token", source: .AuthHandler)
            } catch {
                Logging.Log(message: "Unable to encode OAuth2 token: (\(error))", source: .AuthHandler)
            }
        }
        else {
            Logging.Log(message: "Could not save OAuth2 token", source: .AuthHandler)
        }
    }
}

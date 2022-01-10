//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  AuthHandler.swift
//  ItslearningAPI

import Foundation
import OAuth2
import Alamofire

/// The main class for doing SSO Authenticated communication with Itslearning
class AuthHandler: ObservableObject {
    /// Create OAuth2 Code Grant using hard-coded values for Itslearning
    /// NOTE: The client id "10ae9d30-1853-48ff-81cb-47b58a325685", is a value extracted from the itslearning app apk file
    public let oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "10ae9d30-1853-48ff-81cb-47b58a325685",
        "authorize_uri": "https://sdu.itslearning.com/oauth2/authorize.aspx",
        "token_uri": "https://sdu.itslearning.com/restapi/oauth2/token",
        "redirect_uris": ["itsl-itslearning://login"],
        "scope": "SCOPE",
        "secret_in_body": false,
        "keychain": false
    ] as OAuth2JSON)
    
    @Published public var loading: Bool = true // I don't like having this here, but the alternative seemed worse
    @Published public var isLoggedIn: Bool = false
    
    /// The constructor creates an AuthHandler instance,
    /// and if successful set the member variable isLoggedIn to true and calls the completion handler with the parameter true.
    /// Otherwise it calls it the completion handler with false
    init() {
        print("Initialising Auth Handler")
        
        print("Reading user defaults")
        guard let authToken = GetAuthToken() else {
            self.loading = false
            return
        }
        
        print("Verifying auth token")
        VerifyAuthToken(authToken: authToken) { success in
            if(success) {
                print("Successfully loaded and verified auth tokens")
                self.isLoggedIn = true
                self.loading = false
            } else {
                print("Could not sign in")
                self.loading = false
            }
        }
    }
    
    /// Reads the AuthToken from user defaults, returns nil if not found
    func GetAuthToken() -> AuthToken? {
        do {
            if let authTokenData = UserDefaults.sharedContainerDefaults.object(forKey: "authToken") {
                let authToken = try JSONDecoder().decode(AuthToken.self, from:  authTokenData as! Data)
                return authToken
            }
        } catch {
            return nil
        }
        return nil
    }
    
    /// Removes the AuthToken from user default and from the current OAuth2 instance
    func LogOut() {
        print("Logging out")
        UserDefaults.sharedContainerDefaults.removeObject(forKey: "authToken")
        oauth2.forgetTokens()
        self.isLoggedIn = false
    }
    
    /// If possible we refresh the AuthToken and save it to user defaults, if the RefreshToken is invalid or there is som other error, we print it
    func ReloadAuthToken(completion: @escaping (Bool)->()) {
        print("Reloading auth token")
        guard let authToken = GetAuthToken() else {
            print("Could not find auth tokens in user defaults")
            completion(false)
            return
        }
        oauth2.accessToken = authToken.accessToken
        oauth2.accessTokenExpiry = authToken.accessTokenDate
        oauth2.refreshToken = authToken.refreshToken
        
        oauth2.doRefreshToken(params: ["federated_login_provider_id": "0"]) { keys, error in
            if let unwrappedError = error {
                print(unwrappedError)
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
        print("Signing in")
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            throw "Cannot sign user in from app extension, please open the app to sign in and reload the app extension"
        }
        
        oauth2.authorizeEmbedded(from: NSString(), params: ["federated_login_provider_id": "0"], callback: { authParameters, error in
            if error == nil && authParameters != nil  {
                print("Authentication successful, saving tokens to user defaults");
                print("Token \(String(describing: self.oauth2.accessToken))")
                self.SaveTokens()
                self.isLoggedIn = true
            }
            else {
                print("Error occured: \(error!)");
            }
        })
    }
    
    /// Verifies the AuthToken by making a request to Itslearning Rest API
    func VerifyAuthToken(authToken: AuthToken, completion: @escaping (Bool)->()) {
        oauth2.accessToken = authToken.accessToken
        oauth2.accessTokenExpiry = authToken.accessTokenDate
        oauth2.refreshToken = authToken.refreshToken
        
        AF.request("https://sdu.itslearning.com/restapi/personal/courses/v1", interceptor: OAuth2RetryHandler(authHandler: self), requestModifier: { $0.timeoutInterval = 5 }).validate().response() { response in
            if(response.response?.statusCode ?? 401 >= 400) {
                completion(false)
            }
            else {
                self.SaveTokens() // TODO: Return false if this method fails
                completion(true)
            }
        }
    }
    
    /// Saves the current tokens to user defaults
    func SaveTokens() {
        if let accessToken = oauth2.accessToken, let refreshToken = oauth2.refreshToken, let accessTokenDate = oauth2.accessTokenExpiry {
            let authToken = AuthToken(accessToken: accessToken, refreshToken: refreshToken, accessTokenDate: accessTokenDate);
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(authToken)
                UserDefaults.sharedContainerDefaults.set(data, forKey: "authToken")
                print("Successfully saved user defaults")
            } catch {
                print("Unable to encode auth token: (\(error))")
            }
        }
        else {
            print("ERROR: Could not save authentication tokens")
        }
    }
}

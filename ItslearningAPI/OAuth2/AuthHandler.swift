//
//  AuthHandler.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 15/09/2021.
//

import Foundation
import OAuth2
import Alamofire

// Prime directive: Keep in sync with user defaults ie. on every request we should read in the refresh token and write it out to userdefaults after we are done
class AuthHandler {
    let oauth2: OAuth2CodeGrant;
    
    
    init() throws {
        print("Initialising Auth Handler")
        // Create OAuth2 Code Grant using hard-coded values for Itslearning
        // NOTE: The client id "10ae9d30-1853-48ff-81cb-47b58a325685", is a value extracted from the itslearning app apk file
        oauth2 = OAuth2CodeGrant(settings: [
            "client_id": "10ae9d30-1853-48ff-81cb-47b58a325685",
            "authorize_uri": "https://sdu.itslearning.com/oauth2/authorize.aspx",
            "token_uri": "https://sdu.itslearning.com/restapi/oauth2/token",
            "redirect_uris": ["itsl-itslearning://login"],
            "scope": "SCOPE",
            "secret_in_body": false,
            "keychain": false
        ] as OAuth2JSON)
        
        print("Reading user defaults")
        do {
            let authToken = try JSONDecoder().decode(AuthToken.self, from: UserDefaults.sharedContainerDefaults.object(forKey: "authToken") as! Data)
            print("Found user defaults")
            ReloadAuthToken(authToken: authToken)
        } catch {
            print("Did not find user defaults")
            try SignIn()
        }
        
    }
    
    func GetAuthToken() -> AuthToken? {
        do {
            let authToken = try JSONDecoder().decode(AuthToken.self, from: UserDefaults.sharedContainerDefaults.object(forKey: "authToken") as! Data)
            return authToken
        } catch {
            return nil
        }
    }
    
    func LogOut() {
        print("Logging out")
        UserDefaults.sharedContainerDefaults.removeObject(forKey: "authToken")
    }
    
    func ReloadAuthToken(authToken: AuthToken) {
        // We found authentication tokens in userdefaults
        oauth2.accessToken = authToken.accessToken
        oauth2.accessTokenExpiry = authToken.accessTokenDate
        oauth2.refreshToken = authToken.refreshToken
        
        oauth2.tryToObtainAccessTokenIfNeeded(params: ["federated_login_provider_id": "0"]) { authParameters, error in
            if error == nil && authParameters != nil  {
                print("Authentication successful, saving tokens to user defaults");
                print("Token \(String(describing: self.oauth2.accessToken!))")
                self.SaveTokens()
                
            }
            else {
                print("Error occured: \(String(describing: error) )");
            }
        }
    }
    
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
            }
            else {
                print("Error occured: \(error!)");
            }
        })
    }
    
    func GetRequest() {
        AF.request("https://sdu.itslearning.com/restapi/personal/courses/v1", interceptor: OAuth2RetryHandler(oauth2: oauth2), requestModifier: { $0.timeoutInterval = 5 }).validate().response() { response in
            debugPrint(response)
        }
    }
    
    
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

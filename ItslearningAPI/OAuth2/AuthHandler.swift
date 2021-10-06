//
//  AuthHandler.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 15/09/2021.
//

import Foundation
import OAuth2
import Alamofire

class AuthHandler: ObservableObject {
    // Create OAuth2 Code Grant using hard-coded values for Itslearning
    // NOTE: The client id "10ae9d30-1853-48ff-81cb-47b58a325685", is a value extracted from the itslearning app apk file
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
    
    func LogOut() {
        print("Logging out")
        UserDefaults.sharedContainerDefaults.removeObject(forKey: "authToken")
        oauth2.forgetTokens()
        self.isLoggedIn = false
    }
    
    // TODO: This functionality should be moved to OAuth2RetryHandler
    func ReloadAuthToken(authToken: AuthToken) {
        // We found authentication tokens in userdefaults
        oauth2.accessToken = authToken.accessToken
        oauth2.accessTokenExpiry = authToken.accessTokenDate
        oauth2.refreshToken = authToken.refreshToken
        
        //        oauth2.tryToObtainAccessTokenIfNeeded(params: ["federated_login_provider_id": "0"]) { authParameters, error in
        //            if error == nil && authParameters != nil  {
        //                print("Authentication successful, saving tokens to user defaults");
        //                print("Token \(String(describing: self.oauth2.accessToken!))")
        //                self.SaveTokens()
        //
        //            }
        //            else {
        //                print("Error occured: \(String(describing: error) )");
        //            }
        //        }
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
                self.isLoggedIn = true
            }
            else {
                print("Error occured: \(error!)");
            }
        })
    }
    
    // TODO: The request functionality should be moved to a different file as an extension to improve readability
    func GetRequest() {
        AF.request("https://sdu.itslearning.com/restapi/personal/courses/v1", interceptor: OAuth2RetryHandler(oauth2: oauth2), requestModifier: { $0.timeoutInterval = 5 }).validate().response() { response in
            debugPrint(response)
        }
    }
    
    func VerifyAuthToken(authToken: AuthToken, completion: @escaping (Bool)->()) {
        oauth2.accessToken = authToken.accessToken
        oauth2.accessTokenExpiry = authToken.accessTokenDate
        oauth2.refreshToken = authToken.refreshToken
        
        AF.request("https://sdu.itslearning.com/restapi/personal/courses/v1", interceptor: OAuth2RetryHandler(oauth2: oauth2), requestModifier: { $0.timeoutInterval = 5 }).validate().response() { response in
            print(response.debugDescription)
            if(response.response?.statusCode ?? 401 >= 400) {
                completion(false)
            }
            else {
                self.SaveTokens()
                completion(true)
            }
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
    
    func GetRequest<T: Decodable>(url: String, type: T.Type = T.self, completion: @escaping ((data: T?, error: AFError?))->()) {
        AF.request(url, interceptor: OAuth2RetryHandler(oauth2: self.oauth2), requestModifier: { $0.timeoutInterval = 5 }).validate().responseDecodable(of: type.self) { response in
            //print(response.debugDescription)
            
            switch response.result {
            case .success(let data):
                completion((data, nil))
            case .failure(let error):
                completion((nil, error))
            }
        }
    }
    
    /// Gets a list of courses from itslearning
    func GetCourses(completion: @escaping ([PersonCourse])->()){
        // TODO: Do paging of API
        let url = "https://sdu.itslearning.com/restapi/personal/courses/v2"
        GetRequest(url: url, type: EntityListOfPersonCourse.self) { response in
            guard let data = response.data else {
                print(response.error ?? "Unknown error")
                completion([])
                return
            }
            completion(data.EntityArray)
        }
    }
    
    // Get list of resources from subfolder or course
    func GetResources(course: Int, folder: Int, completion: @escaping ([CourseResource])->()) {
        let isRootFolder = folder == 0;
        let url = isRootFolder ? "https://sdu.itslearning.com/restapi/personal/courses/\(course)/resources/v1" : "https://sdu.itslearning.com/restapi/personal/courses/\(course)/folders/\(folder)/resources/v1";
        
        GetRequest(url: url, type: CourseFolderDetails.self) { response in
            guard let data = response.data else {
                print(response.error ?? "Unknown error")
                completion([])
                return;
            }
            completion(data.Resources.EntityArray)
        }
        
    }
}

//
//  FileProviderEnumerator.swift
//  Itslearning
//
//  Copied from: https://github.com/p2/OAuth2/wiki/Alamofire-5
//

import Foundation
import OAuth2
import Alamofire

/// This is a modification of the RetryHandler from the OAuth2 library, which gives it the ability to intercept AlamoFire requests and if there is a 401 Unauthorized HTTP code, we try to refresh the token, since this response could be a sign that the AuthToken has expired(which it does after 3600 seconds)
class OAuth2RetryHandler: Alamofire.RequestInterceptor {
    
    let authHandler: AuthHandler
    let loader: OAuth2DataLoader

    init(authHandler: AuthHandler) {
        self.authHandler = authHandler
        loader = OAuth2DataLoader(oauth2: self.authHandler.oauth2)
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        if let response = request.task?.response as? HTTPURLResponse, 401 == response.statusCode, let req = request.request {
            var dataRequest = OAuth2DataRequest(request: req, callback: { _ in })

            dataRequest.context = completion
            loader.enqueue(request: dataRequest)
            authHandler.ReloadAuthToken { success in
                self.loader.dequeueAndApply() { req in
                    if let comp = req.context as? (RetryResult) -> Void {
                        comp(success ? .retry : .doNotRetry)
                    }
                }
            }
        }
        else {
             completion(.doNotRetry)   // not a 401, not our problem
        }
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard nil != loader.oauth2.accessToken else {
            completion(.success(urlRequest))
            return
        }
        
        do {
            let request = try urlRequest.signed(with: loader.oauth2)
            
            return completion(.success(request))
        } catch {
            print("Unable to sign request: \(error)")
            return completion(.failure(error))
        }
    }
}

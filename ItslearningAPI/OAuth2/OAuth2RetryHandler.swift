//
//  FileProviderEnumerator.swift
//  Itslearning
//
//  Copied from: https://github.com/p2/OAuth2/wiki/Alamofire-5
//

import Foundation
import OAuth2
import Alamofire

class OAuth2RetryHandler: Alamofire.RequestInterceptor {
    
    let loader: OAuth2DataLoader

    init(oauth2: OAuth2) {
        loader = OAuth2DataLoader(oauth2: oauth2)
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
//        if let response = request.task?.response as? HTTPURLResponse, 401 == response.statusCode, let req = request.request {
//            var dataRequest = OAuth2DataRequest(request: req, callback: { _ in })
//
//            dataRequest.context = completion
//            loader.enqueue(request: dataRequest)
//            loader.attemptToAuthorize() { authParams, error in
//                self.loader.dequeueAndApply() { req in
//                    if let comp = req.context as? (RetryResult) -> Void {
//                        comp(nil != authParams ? .retry : .doNotRetry)
//                    }
//                }
//            }
//        }
//        else {
             completion(.doNotRetry)   // not a 401, not our problem
//        }
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

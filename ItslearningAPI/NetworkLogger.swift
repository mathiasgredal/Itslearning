//
//  NetworkLogger.swift
//  Itslearning
//
//  Created by Mathias Gredal on 2022-01-12.
//  Based on: https://github.com/konkab/AlamofireNetworkActivityLogger

import Foundation
import Alamofire

public class NetworkLogger {
    public static let shared = NetworkLogger()
    
    private let queue = DispatchQueue(label: "\(NetworkLogger.self) Queue")
    
    deinit {
        stopLogging()
    }
    
    public func startLogging() {
        stopLogging()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(NetworkLogger.requestDidFinish(notification:)),
            name: Request.didFinishNotification,
            object: nil
        )
    }
    public func stopLogging() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func requestDidFinish(notification: Notification) {
        queue.async {
            guard let dataRequest = notification.request as? DataRequest,
                  let task = dataRequest.task,
                  let metrics = dataRequest.metrics,
                  let request = task.originalRequest,
                  let httpMethod = request.httpMethod,
                  let requestURL = request.url
            else {
                return
            }
            
            let elapsedTime = metrics.taskInterval.duration
            
            if let error = task.error {
                Logging.Log(message: "[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]: \(error)", source: .Network)
            } else {
                guard let response = task.response as? HTTPURLResponse else {
                    return
                }
                
                Logging.Log(message: "\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]", source: .Network)
            }
        }
    }
}

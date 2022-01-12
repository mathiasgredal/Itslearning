//
//  Logging.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 2022-01-12.
//

import Foundation
import OSLog

public struct Logging {
    static let logfile = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupId)?.appendingPathComponent("itslearning.log")
    
    enum LogSources: String {
        case FileProvider
        case AuthHandler
        case MainApp
    }
 
    static func Log(message: String, source: LogSources) {
        guard let logfile = Logging.logfile else {
            // An invalid app group id was presumably passed
            print("Error: Could not find location for log(check app group id)")
            return
        }
        
        let log = "\(source)[\(Date.getCurrentDate())]: \(message)\n"

        do {
            let data = log.data(using: String.Encoding.utf8)!
            try data.append(fileURL: logfile)
        } catch {
            print("Error: Could not update log")
        }
    }
    
    static func Clear() {
        // TODO: Implement this
    }
}

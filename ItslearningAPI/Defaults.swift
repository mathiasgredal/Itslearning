//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  Defaults.swift
//  ItslearningAPI

import Foundation

extension String: Error {}

struct Constants {
     static let appGroupId = "ZF8FHQ365P."
}

extension Notification.Name {
    static let urlopened = Notification.Name("urlopened")
}

public extension UserDefaults {
    static var sharedContainerDefaults: UserDefaults {
        // Suitename is the app group id
        guard let defaults = UserDefaults(suiteName: Constants.appGroupId) else {
            fatalError("could not access shared user defaults")
        }
        return defaults
    }
}

// From: https://stackoverflow.com/a/40687742
extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

extension Date {
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    static func getCurrentDate() -> String {
        return Date().getFormattedDate()
    }
}

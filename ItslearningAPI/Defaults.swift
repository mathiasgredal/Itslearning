//
//  Defaults.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 15/09/2021.
//

import Foundation

extension String: Error {}

extension Notification.Name {
    static let urlopened = Notification.Name("urlopened")
}

public extension UserDefaults {
    static var sharedContainerDefaults: UserDefaults {
        // Suitename is the app group id
        guard let defaults = UserDefaults(suiteName: "ZF8FHQ365P.") else {
            fatalError("could not access shared user defaults")
        }
        return defaults
    }
}

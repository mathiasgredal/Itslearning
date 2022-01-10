//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  Defaults.swift
//  ItslearningAPI

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

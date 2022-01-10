//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  AuthToken.swift
//  ItslearningAPI

import Foundation

struct AuthToken: Codable {
    var accessToken: String
    var refreshToken: String
    var accessTokenDate: Date
    
    init(accessToken: String, refreshToken: String, accessTokenDate: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenDate = accessTokenDate

    }
}

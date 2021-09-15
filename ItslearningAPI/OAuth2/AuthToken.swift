//
//  AuthToken.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 15/09/2021.
//

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

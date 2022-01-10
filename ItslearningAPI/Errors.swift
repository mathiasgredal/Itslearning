//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  Errors.swift
//  ItslearningAPI

import Foundation

public enum CommonError: Error, Codable, LocalizedError {
    public static let errorHeader = "X-API-Error"

    internal enum Values: String, Codable {
        case internalError
        case clientCrashingError
        case notImplemented
        case timedOut
        case parameterError
        case authRequired
        case accountExists
        case tokenExpired
    }

    internal enum CodingKeys: String, CodingKey {
        case value
        case entry
        case identifier
        case errorDomain
        case errorCode
        case errorLocalizedDescription
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Values.self, forKey: .value) {
        case .internalError:
            self = .internalError
        case .clientCrashingError:
            self = .clientCrashingError
        case .notImplemented:
            self = .notImplemented
        case .timedOut:
            self = .timedOut
        case .parameterError:
            self = .parameterError
        case .authRequired:
            self = .authRequired
        case .accountExists:
            self = .accountExists
        case .tokenExpired:
            self = .tokenExpired
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .internalError:
            try container.encode(Values.internalError, forKey: .value)
        case .clientCrashingError:
            try container.encode(Values.clientCrashingError, forKey: .value)
        case .notImplemented:
            try container.encode(Values.notImplemented, forKey: .value)
        case .timedOut:
            try container.encode(Values.timedOut, forKey: .value)
        case .parameterError:
            try container.encode(Values.parameterError, forKey: .value)
        case .authRequired:
            try container.encode(Values.authRequired, forKey: .value)
        case .accountExists:
            try container.encode(Values.accountExists, forKey: .value)
        case .tokenExpired:
            try container.encode(Values.tokenExpired, forKey: .value)
        }
    }

    case internalError
    case clientCrashingError
    case notImplemented
    case timedOut
    case parameterError
    case authRequired
    case accountExists
    case tokenExpired

    public var errorDescription: String? {
        return "\(self)"
    }
}

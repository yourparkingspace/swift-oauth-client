//
//  OAuthClientError.swift
//  OAuthClient
//
//  Created by Jack Nicholson Colley on 19/04/2021.
//

import Foundation

public enum OAuthClientError: Error {
    case genericWithMessage(String)
    case tokenExpired
    case errorReadingTokenFromStorage(Error?)
    case requires2fa(TwoFactorResponse)
}

extension OAuthClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .genericWithMessage(let message):
            return NSLocalizedString("\(message)", comment: "")
        case .tokenExpired:
            return NSLocalizedString("Token expired", comment: "")
        case .errorReadingTokenFromStorage(let error):
            return NSLocalizedString("Error reading token from storage \(error?.localizedDescription ?? "")", comment: "")
        case .requires2fa(let response):
            return NSLocalizedString("Requires 2FA", comment: "")
        }
    }
}

//
//  OAuthGrantType.swift
//  OAuthClient
//
//  Created by Jack Nicholson Colley on 16/04/2021.
//

import Foundation

public enum OAuthGrantType: Equatable {
    /// A client credentials grant type - no params needed
    case clientCredentials

    /// A password grant
    ///
    /// - parameter username: The username to log in with.
    /// - parameter password: The password to log in with.
    /// - parameter twoFactorScheme: The string representation of the two factor scheme used
    /// - parameter twoFactorCode: The two factor code
    ///
    case password(String, String, String?, String?)

    /// A refresh token grant
    ///
    /// - parameter refreshToken: The refresh token to use
    case refresh(String)

    /// A custom grant
    ///
    /// - parameter grantType: The grant type property to pass through
    /// - parameter params: A dictionary of paramters to pass through
    case custom(String, [String : String])

    /// Returns the paramets to send for a grant type
    
    public var params: [String : String] {
        switch self {
        case .clientCredentials:
            return [
                "grant_type": "client_credentials"
            ]
        case .password(let username, let password, let twoFactorScheme, let twoFactorCode):
            var tempParams: [String : String] = [:]
            
            tempParams["grant_type"] = "password"
            tempParams["username"] = username
            tempParams["password"] = password
            
            if let twoFactorScheme = twoFactorScheme {
                tempParams["two_factor_scheme"] = twoFactorScheme
            }
            if let twoFactorCode = twoFactorCode {
                tempParams["two_factor_code"] = twoFactorCode
            }
            
            return tempParams
        case .refresh(let refreshToken):
            return [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
        case .custom(let grantType, var userDefinedParams):
            userDefinedParams["grant_type"] = grantType

            return userDefinedParams
        }
    }

    public var storageKey: String {
        switch self {
        case .clientCredentials:
            return "client"
        default:
            return "password"
        }
    }
}

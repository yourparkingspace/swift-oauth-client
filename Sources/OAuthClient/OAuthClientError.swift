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
}

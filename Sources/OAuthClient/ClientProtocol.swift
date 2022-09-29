//
//  ClientProtocol.swift
//  
//
//  Created by Jack Nicholson Colley on 13/05/2021.
//

import Foundation

public protocol Client {
	func authenticateRequest(_ request: URLRequest, grantType: OAuthGrantType) async throws -> URLRequest
	func requestToken(for grantType: OAuthGrantType) async throws -> OAuthAccessToken
	func fetchStoredToken(type: OAuthGrantType) async throws -> OAuthAccessToken
    func logout()
    func clearTokens()
}

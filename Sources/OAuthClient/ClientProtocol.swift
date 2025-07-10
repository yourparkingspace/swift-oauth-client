//
//  ClientProtocol.swift
//  
//
//  Created by Jack Nicholson Colley on 13/05/2021.
//

import Foundation

public protocol Client {
    func authenticateRequest(_ request: URLRequest, successBlock: @escaping (URLRequest) -> Void, errorBlock: @escaping (Error?) -> Void)
    func requestToken(for grantType: OAuthGrantType, completion: @escaping (Result<OAuthAccessToken, Error>) -> Void)
    func fetchStoredToken(type: OAuthGrantType, completion: @escaping (Result<OAuthAccessToken, Error>) -> Void)
    func updateStoredToken(token: OAuthAccessToken, storageKey: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func logout()
    func clearTokens()
    //test
}

//
//  ClientProtocol.swift
//  
//
//  Created by Jack Nicholson Colley on 13/05/2021.
//

import Foundation

public protocol Client {
    func requestToken(for grantType: OAuthGrantType, completion: @escaping (Result<OAuthAccessToken, Error>) -> Void)
    func fetchStoredToken(type: OAuthGrantType, completion: @escaping (Result<OAuthAccessToken, Error>) -> Void)
    func logout()
}

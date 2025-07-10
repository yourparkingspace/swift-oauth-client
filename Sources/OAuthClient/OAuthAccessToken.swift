//
//  OAuthAccessToken.swift
//  OAuthClient
//
//  Created by Jack Nicholson Colley on 16/04/2021.
//

import Foundation

public struct OAuthAccessToken: Codable {
    public let accessToken: String
    public let tokenType: String
    public let expiresAt: Date
    public let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresAt = "expires_in"
        case refreshToken = "refresh_token"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        accessToken = try values.decode(String.self, forKey: .accessToken)
        tokenType = try values.decode(String.self, forKey: .tokenType)

        let expiresIn = try values.decode(TimeInterval.self, forKey: .expiresAt)
        expiresAt = Date(timeIntervalSinceNow: expiresIn)

        refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
    }

    public init(accessToken: String, tokenType: String, expiresAt: Date, refreshToken: String?) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
    }

    public func isExpired() -> Bool {
        return expiresAt <= Date()
    }
}

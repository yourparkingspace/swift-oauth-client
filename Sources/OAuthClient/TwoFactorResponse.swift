//
//  TwoFactorResponse.swift
//  OAuthClient
//
//  Created by Jack Nicholson Colley on 29/07/2025.
//

public struct TwoFactorResponse: Codable {
    public let result: String
    public let schemes: Schemes
}

public struct Schemes: Codable {
    public let email: Scheme?
    public let sms: Scheme?
}

public struct Scheme: Codable {
    public let configured: Bool
    public let triggerRoute: String?
    public let destination: String?

    enum CodingKeys: String, CodingKey {
        case configured
        case triggerRoute = "trigger_route"
        case destination
    }
}

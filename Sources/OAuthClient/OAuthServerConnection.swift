//
//  File.swift
//  
//
//  Created by Jack Nicholson Colley on 29/04/2021.
//

import Foundation

public struct OAuthServerConnection {
    public let serverURL: URL
    public let clientID: String
    public let clientSecret: String

    public init(url: URL, clientID: String, clientSecret: String) {
        self.serverURL = url
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}

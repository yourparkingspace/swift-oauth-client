//
//  OAuthClient.swift
//  OAuthClient
//
//  Created by Jack Nicholson Colley on 19/04/2021.
//

import Foundation

public class OAuthClient: Client {
    private let keychainHelper: KeychainInteractor

    private let session: URLSession
    
    private let serverConnectionBuilder: () -> OAuthServerConnection
    
    private var serverConnection: OAuthServerConnection {
        serverConnectionBuilder()
    }

    private let tokenURLUserDefaultsKey = "oauth_client_token_url"
    
    public init(session: URLSession = URLSession(configuration: .default),
                keychain: KeychainInteractor? = nil,
                connectionBuilder: @escaping () -> OAuthServerConnection) {
        self.session = session
        self.keychainHelper = keychain ?? KeychainHelper()
        self.serverConnectionBuilder = connectionBuilder

        let defaults = UserDefaults.standard
        let newTokenURL = serverConnection.serverURL.absoluteString

        if let storedTokenURL = defaults.string(forKey: tokenURLUserDefaultsKey) {

            if storedTokenURL != newTokenURL {
                clearTokens()
                defaults.set(newTokenURL, forKey: tokenURLUserDefaultsKey)
            }
        } else {
            defaults.set(newTokenURL, forKey: tokenURLUserDefaultsKey)
            clearTokens()
        }
    }

	public func requestToken(for grantType: OAuthGrantType) async throws -> OAuthAccessToken {
		var request = URLRequest(url: serverConnection.serverURL)
		request.httpMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

		request.setHTTPAuthorization(.basicAuthentication(username: serverConnection.clientID, password: serverConnection.clientSecret))
		request.setHTTPBody(parameters: buildParamsForRequest(grant: grantType))

		let (data, _) = try await URLSession.shared.data(for: request)

		let token = try JSONDecoder().decode(OAuthAccessToken.self, from: data)
		let _ = self.keychainHelper.update(token, withKey: grantType.storageKey)
		return token

	}

	public func fetchStoredToken(type: OAuthGrantType) async throws -> OAuthAccessToken {
        try keychainHelper.read(withKey: type.storageKey)
	}

	public func authenticateRequest(_ request: URLRequest, grantType: OAuthGrantType) async throws -> URLRequest {
        let token: OAuthAccessToken = try await fetchStoredToken(type: grantType)
		var requestToReturn = request
		requestToReturn.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
		return requestToReturn
	}

    public func logout() {
        let _ = keychainHelper.remove(withKey: OAuthGrantType.password("", "").storageKey)
    }

    public func clearTokens() {
        let _ = keychainHelper.remove(withKey: OAuthGrantType.password("", "").storageKey)
        let _ = keychainHelper.remove(withKey: OAuthGrantType.clientCredentials.storageKey)
    }

    private func buildParamsForRequest(grant: OAuthGrantType) -> [String: String] {
        var params = grant.params
        params["client_id"] = serverConnection.clientID
        params["client_secret"] = serverConnection.clientSecret

        return params
    }
}

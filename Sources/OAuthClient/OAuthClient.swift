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

    public func requestToken(for grantType: OAuthGrantType, completion: @escaping (Result<OAuthAccessToken, Error>) -> Void) {
        var request = URLRequest(url: serverConnection.serverURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.setHTTPAuthorization(.basicAuthentication(username: serverConnection.clientID, password: serverConnection.clientSecret))
        request.setHTTPBody(parameters: buildParamsForRequest(grant: grantType))


        session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }

            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(OAuthClientError.genericWithMessage("No Response")))
                }
                return
            }

            if response.statusCode != 200 {
                DispatchQueue.main.async {
                    completion(.failure(OAuthClientError.genericWithMessage("Invalid status code. Expecting 200, got \(response.statusCode)")))
                }
                return
            }

            guard let data = data, data.isEmpty == false else {
                DispatchQueue.main.async {
                    completion(.failure(OAuthClientError.genericWithMessage("No data received")))
                }
                return
            }
            
            let decoder = JSONDecoder()

            do {
                let token = try decoder.decode(OAuthAccessToken.self, from: data)

                DispatchQueue.main.async {
                    let success = self.keychainHelper.update(token, withKey: grantType.storageKey)

                    if success {
                        completion(.success(token))
                    } else {
                        completion(.failure(OAuthClientError.genericWithMessage("Unable to store token")))
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    public func authenticateRequest(_ request: URLRequest, successBlock: @escaping (URLRequest) -> Void, errorBlock: @escaping (Error?) -> Void) {

        fetchStoredToken(type: .password("", "")) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                var requestToReturn = request
                requestToReturn.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")

                successBlock(requestToReturn)
            case .failure(_):
                self.fetchStoredToken(type: .clientCredentials) { clientResult in
                    switch clientResult {
                    case .success(let clientToken):
                        var requestToReturn = request
                        requestToReturn.addValue("Bearer \(clientToken.accessToken)", forHTTPHeaderField: "Authorization")

                        successBlock(requestToReturn)
                    case .failure(_):
                        self.requestToken(for: .clientCredentials) { [weak self] newClientCredentialsResult in
                            switch newClientCredentialsResult {
                            case .success(let newClientToken):
                                var requestToReturn = request
                                requestToReturn.addValue("Bearer \(newClientToken.accessToken)", forHTTPHeaderField: "Authorization")

                                successBlock(requestToReturn)
                            case .failure(let clientCredentialsTokenError):
                                self?.clearTokens()
                                errorBlock(clientCredentialsTokenError)
                            }
                        }
                    }
                }
            }
        }
    }

    public func fetchStoredToken(type: OAuthGrantType, completion: @escaping (Result<OAuthAccessToken, Error>) -> Void) {
        do {
            let token: OAuthAccessToken = try keychainHelper.read(withKey: type.storageKey)

            if token.isExpired() {

                guard let refreshToken = token.refreshToken else {

                    let _ = keychainHelper.remove(withKey: type.storageKey)
                    completion(.failure(OAuthClientError.tokenExpired))

                    return
                }

                requestToken(for: OAuthGrantType.refresh(refreshToken), completion: completion)
                return
            }

            completion(.success(token))

        } catch let error {
            completion(.failure(OAuthClientError.errorReadingTokenFromStorage(error)))
        }
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

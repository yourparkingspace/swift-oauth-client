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

    private let serverConnection: OAuthServerConnection

    public init(session: URLSession = URLSession(configuration: .default),
                connection: OAuthServerConnection,
                keychain: KeychainInteractor? = nil) {
        self.session = session
        self.serverConnection = connection
        self.keychainHelper = keychain ?? KeychainHelper()
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

    private func buildParamsForRequest(grant: OAuthGrantType) -> [String: String] {
        var params = grant.params
        params["client_id"] = serverConnection.clientID
        params["client_secret"] = serverConnection.clientSecret

        return params
    }
}

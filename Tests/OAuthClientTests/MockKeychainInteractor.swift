//
//  MockKeychainInteractor.swift
//  OAuthClientTests
//
//  Created by Jack Nicholson Colley on 27/04/2021.
//

import Foundation
import OAuthClient

class MockKeychainInteractor: KeychainInteractor {

    var keychainItems: [String: Any] = [:]

    var isSuccess = true

    func add<T>(_ value: T, withKey key: String) throws where T : Decodable, T : Encodable {
        keychainItems[key] = value
    }

    func update<T>(_ value: T, withKey key: String) -> Bool where T : Decodable, T : Encodable {
        keychainItems[key] = value

        return isSuccess
    }

    func remove(withKey key: String) -> Bool {
        guard let index = keychainItems.index(forKey: key) else { return false }
        keychainItems.remove(at: index)

        return isSuccess
    }

    func read<T>(withKey key: String) throws -> T where T : Decodable, T : Encodable {
        if let value = keychainItems[key] as? T {
            return value
        } else {
            throw OAuthClientError.genericWithMessage("No value for key")
        }
    }


}

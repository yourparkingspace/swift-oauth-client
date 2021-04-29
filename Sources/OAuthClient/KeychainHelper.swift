//
//  KeychainHelper.swift
//  OAuthClient
//
//  Created by Jack Nicholson Colley on 19/04/2021.
//

import Foundation
import Security

// Mostly taken from Apples example
// https://developer.apple.com/documentation/localauthentication/accessing_keychain_items_with_face_id_or_touch_id

public struct KeychainError: Error {
    var status: OSStatus

    var localizedDescription: String {
        if #available(iOS 11.3, *) {
            return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        } else {
            return "Unknown error"
        }
    }
}

public protocol KeychainInteractor {
    func add<T: Codable> (_ value: T, withKey key: String) throws
    func update<T: Codable> (_ value: T, withKey key: String) -> Bool
    func remove (withKey key: String) -> Bool
    func read <T: Codable> (withKey key: String) throws -> T
}

public struct KeychainHelper: KeychainInteractor {
    public init() {}
    
    public func add<T: Codable> (_ value: T, withKey key: String) throws {

        let encoded = try JSONEncoder().encode(value)

        // Build the query for use in the add operation.
        let query: [String: Any?] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: key,
                                     kSecValueData as String: encoded]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }

    @discardableResult
    public func update<T: Codable> (_ value: T, withKey key: String) -> Bool {
        remove(withKey: key)

        do {
            try add(value, withKey: key)
        } catch {
            return false
        }
        return true
    }

    /// Returns if the removal was successful
    @discardableResult
    public func remove (withKey key: String) -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key]

        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    public func read <T: Codable> (withKey key: String) throws -> T {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { throw KeychainError(status: status) }

        guard let existingItem = item as? [String: Any],
              let data = existingItem[kSecValueData as String] as? Data
        else {
            throw KeychainError(status: errSecInternalError)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

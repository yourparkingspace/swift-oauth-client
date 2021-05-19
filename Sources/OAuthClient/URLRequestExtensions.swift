//
//  URLRequestExtensions.swift
//  
//
//  Created by Jack Nicholson Colley on 19/05/2021.
//

import Foundation

/// An HTTP authentication is used for authorizing requests to either the token
/// or the resource endpoint.
public enum HTTPAuthentication: Equatable {
    /// HTTP Basic Authentication.
    ///
    /// - parameter username: The username.
    /// - parameter password: The password.
    case basicAuthentication(username: String, password: String)

    /// Returns the authentication encoded as `String` suitable for the HTTP
    /// `Authorization` header.
    fileprivate var value: String? {
        switch self {
        case let .basicAuthentication(username, password):
            if let credentials = "\(username):\(password)"
                .data(using: String.Encoding.ascii)?
                .base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
                return "Basic \(credentials)"
            } else {
                return nil
            }
        }
    }
}

public func == (lhs: HTTPAuthentication, rhs: HTTPAuthentication) -> Bool {
    switch (lhs, rhs) {
    case let (.basicAuthentication(lusername, lpassword), .basicAuthentication(rusername, rpassword)):
        return lusername == rusername
            && lpassword == rpassword
    }
}

private let HTTPRequestHeaderFieldAuthorization = "Authorization"

public extension URLRequest {
    /// Returns the HTTP `Authorization` header value or `nil` if not set.
    var HTTPAuthorization: String? {
        return value(forHTTPHeaderField: HTTPRequestHeaderFieldAuthorization)
    }

    /// Sets the HTTP `Authorization` header value.
    ///
    /// - parameter value: The value to be set or `nil`.
    ///
    /// TODO: Declarations in extensions cannot override yet.
    mutating func setHTTPAuthorization(_ value: String?) {
        setValue(value, forHTTPHeaderField: HTTPRequestHeaderFieldAuthorization)
    }

    /// Sets the HTTP `Authorization` header value using the given HTTP
    /// authentication.
    ///
    /// - parameter authentication: The HTTP authentication to be set.
    mutating func setHTTPAuthorization(_ authentication: HTTPAuthentication) {
        setHTTPAuthorization(authentication.value)
    }

    /// Sets the HTTP body using the given paramters encoded as query string.
    ///
    /// - parameter parameters: The parameters to be encoded.
    ///
    mutating func setHTTPBody(parameters: [String: String]) {
        var components: [(String, String)] = []
        for (key, value) in parameters {
            components += queryComponents(key, value)
        }
        let bodyString = components.map { "\($0)=\($1)" }.joined(separator: "&")
        httpBody = bodyString.data(using: String.Encoding.utf8)
    }

    // Taken from https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift#L176
    private func queryComponents(_ key: String, _ value: String) -> [(String, String)] {
        var components: [(String, String)] = []

        components.append((escape(key), escape(value)))

        return components
    }

    // Taken from https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift#L210
    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}

//
//  OAuthClientTests.swift
//  OAuthClientTests
//
//  Created by Jack Nicholson Colley on 27/04/2021.
//

import XCTest
import Foundation
import OAuthClient

class OAuthClientTests: XCTestCase {

    let keychainHelper = KeychainHelper()
    var client: OAuthClient!

    let keychain = MockKeychainInteractor()

    let connectionBuilder = {
        OAuthServerConnection(url: URL(string: "https://test.com")!,
                                     clientID: "1",
                                     clientSecret: "abcdef")
    }

    let stagingConnectionBuilder = {
        OAuthServerConnection(url: URL(string: "https://staging.test.com")!,
                              clientID: "1",
                              clientSecret: "abcdef")
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)

        client = OAuthClient(session: urlSession,
                             keychain: keychain,
                             connectionBuilder: connectionBuilder)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let _ = keychain.remove(withKey: OAuthGrantType.clientCredentials.storageKey)
        let _ = keychain.remove(withKey: OAuthGrantType.password("", "").storageKey)
    }

    func testTokensRemovedIfInvalidRefresh() throws {
        let _ = keychain.remove(withKey: "password")
        let _ = keychain.remove(withKey: "client")

        let jsonData = TestStrings.oAuthTokenResponseExpiredWithRefresh.data(using: .utf8)

        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        try keychain.add(tokenToStore, withKey: "password")
        try keychain.add(tokenToStore, withKey: "client")

        XCTAssertEqual(keychain.keychainItems.count, 2)

        let passwordToken: OAuthAccessToken? = try keychain.read(withKey: "password")
        let clientToken: OAuthAccessToken? = try keychain.read(withKey: "client")

        XCTAssertNotNil(passwordToken)
        XCTAssertNotNil(clientToken)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        let expect = expectation(description: "Token is returned")

        client.requestToken(for: .refresh((passwordToken?.refreshToken)!), completion: { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(_):
                XCTAssertNil(self.keychain.keychainItems["password"])
                XCTAssertNil(self.keychain.keychainItems["client"])
                XCTAssertEqual(self.keychain.keychainItems.count, 0)
                expect.fulfill()
            }
        })

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testClientCanDecodeTokenWhenRequested() throws {
        
        let mockToken = TestStrings.oAuthTokenResponse.data(using: .utf8)

        let expect = expectation(description: "Token is returned")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockToken!)
        }

        client.requestToken(for: .password("email@email.com", "password")) { (result) in
            switch result {
            case.success(_):
                expect.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testClientCanDecodeTokenWithoutRefreshTokenWhenRequested() throws {
        let mockToken = TestStrings.oAuthTokenResponseNoRefresh.data(using: .utf8)

        let expect = expectation(description: "OAuth token is decoded and returned without a refresh token")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockToken!)
        }

        client.requestToken(for: .password("email@email.com", "password")) { (result) in
            switch result {
            case.success(_):
                expect.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testResponseStatusCodeIsHandledGracefully() throws {
        let expect = expectation(description: "Result is returned but failed due to incorrect status code")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        client.requestToken(for: .password("test@test.com", "password")) { (result) in
            switch result {
            case .success(_):
                XCTFail("Token was returned - expected failure")
            case .failure(let error):
                let decodedError = error as! OAuthClientError
                switch decodedError {
                case .genericWithMessage(let message):
                    XCTAssertTrue(message.lowercased().contains("invalid status code"), "Actual message \(message)")
                default:
                    XCTFail("Wrong error type")
                }

                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testNoResponseIsHandledGracefully() throws {
        let expect = expectation(description: "Result is returned but failed due to no response")

        MockURLProtocol.requestHandler = { request in
            return (nil, nil)
        }

        client.requestToken(for: .password("email@email.com", "password")) { (result) in
            switch result {
            case .success(_):
                XCTFail("Token was returned - expected failure")
            case .failure(let error):
                let decodedError = error as! OAuthClientError
                switch decodedError {
                case .genericWithMessage(let message):
                    XCTAssertTrue(message.lowercased().contains("no response"), "Actual message \(message)")
                default:
                    XCTFail("Wrong error type")
                }

                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testNoDataIsHandedGracefully() throws {
        let expect = expectation(description: "Result is returned but failed due to no response")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        client.requestToken(for: .password("email@email.com", "password")) { (result) in
            switch result {
            case .success(_):
                XCTFail("Token was returned - expected failure")
            case .failure(let error):
                let decodedError = error as! OAuthClientError
                switch decodedError {
                case .genericWithMessage(let message):
                    XCTAssertTrue(message.lowercased().contains("no data"), "Actual message \(message)")
                default:
                    XCTFail("Wrong error type")
                }

                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testKeychainStorageIsAskedToStoreToken() throws {
        let expect = expectation(description: "Token is stored in keychain")

        let mockToken = TestStrings.oAuthTokenResponse.data(using: .utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockToken)
        }

        client.requestToken(for: .password("test@test.com", "password")) { (result) in
            switch result {
            case .success(_):
                XCTAssertNotNil(self.keychain.keychainItems["password"])
                expect.fulfill()
            case .failure(_):
                XCTFail("Error was returned")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testKeychainStorageFailsIsHandledGracefully() throws {
        let expect = expectation(description: "Token storage failure is handled")

        let mockToken = TestStrings.oAuthTokenResponse.data(using: .utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockToken)
        }

        let failingKeychain = MockKeychainInteractor()
        failingKeychain.isSuccess = false
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        let failureClient = OAuthClient(session: urlSession,
                                        keychain: failingKeychain,
                                        connectionBuilder: connectionBuilder)

        failureClient.requestToken(for: OAuthGrantType.password("test@test.com", "password")) { (result) in
            switch result {
            case .success(_):
                XCTFail("Success was returned")
            case .failure(let error):
                let decodedError = error as! OAuthClientError
                switch decodedError {
                case .genericWithMessage(let message):
                    XCTAssertTrue(message.lowercased().contains("unable to store token"), "Actual message \(message)")
                default:
                    XCTFail("Wrong error type")
                }
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testMalformedTokenResponseIsHandledGracefully() throws {
        let expect = expectation(description: "Error is handled")

        let mockToken = TestStrings.oAuthTokenResponseMalformed.data(using: .utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockToken)
        }

        client.requestToken(for: .password("test@test.com", "password")) { (result) in
            switch result {
            case .success(_):
                XCTFail("Success was returned - expecting failure")
            case .failure(_):
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRequestErrorIsHandledGracefully() throws {
        let expect = expectation(description: "Error is thrown")

        MockURLProtocol.requestHandler = { request in
            throw OAuthClientError.genericWithMessage("Request Error")
        }

        client.requestToken(for: .password("test@test.com", "password")) { (result) in
            switch result {
            case .success(_):
                XCTFail("Success was returned - expecting failure")
            case .failure(_):
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testStoredTokenCanBeFetched() throws {
        let expect = expectation(description: "token is fetched from storage")

        let jsonData = TestStrings.oAuthTokenResponse.data(using: .utf8)

        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        try keychain.add(tokenToStore, withKey: "password")

        client.fetchStoredToken(type: .password("", "")) { (result) in
            switch result {
            case .success(let token):
                XCTAssertEqual(tokenToStore.accessToken, token.accessToken)
                expect.fulfill()
            case .failure(_):
                XCTFail("expecting success - got error")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchingAnExpiredTokenIsHandledWhenNoRefreshTokenIsAvailable() throws {
        let expect = expectation(description: "Failure is returned because we can't refresh the token")

        let jsonData = TestStrings.oAuthTokenResponseExpired.data(using: .utf8)

        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        try keychain.add(tokenToStore, withKey: "password")

        let mockRefreshedToken = TestStrings.oAuthTokenResponse.data(using: .utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockRefreshedToken)
        }

        client.fetchStoredToken(type: .password("", "")) { (result) in
            switch result {
            case .success(_):
                XCTFail("expecting failure - got success")
            case .failure(_):
                expect.fulfill()

            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchingAnExpiredTokenIsHandledWhenRefreshTokenIsAvailable() throws {
        let expect = expectation(description: "Expired token is refreshed and the new token is returned")

        let jsonData = TestStrings.oAuthTokenResponseExpiredWithRefresh.data(using: .utf8)

        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        try keychain.add(tokenToStore, withKey: "password")

        let mockRefreshedToken = TestStrings.oAuthTokenResponse.data(using: .utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockRefreshedToken)
        }

        client.fetchStoredToken(type: .password("", "")) { (result) in
            switch result {
            case .success(_):
                expect.fulfill()
            case .failure(_):
                XCTFail("expecting success - got failure")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchingATokenErrorIsHandledGracefully() throws {
        let expect = expectation(description: "Error is thrown and handled")


        let mockRefreshedToken = TestStrings.oAuthTokenResponse.data(using: .utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockRefreshedToken)
        }

        client.fetchStoredToken(type: .password("", "")) { (result) in
            switch result {
            case .success(_):
                XCTFail("expecting failure - got success")
            case .failure(_):
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testLogoutWorksCorrectly() throws {
        let expect = expectation(description: "Token is deleted")

        let jsonData = TestStrings.oAuthTokenResponse.data(using: .utf8)

        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        try keychain.add(tokenToStore, withKey: "password")

        // Verify the token is infact stored
        client.fetchStoredToken(type: .password("", "")) { [weak self] result in
            guard let self = self else {
                XCTFail()
                return
            }

            switch result {
            case .success(let returnedToken):
                XCTAssertEqual(returnedToken.accessToken, tokenToStore.accessToken)
                // Perform the logout
                self.client.logout()

                // Verify we can no longer fetch a stored password token
                self.client.fetchStoredToken(type: .password("", "")) { secondResult in
                    switch secondResult {
                    case .success(_):
                        XCTFail("Token was still retreived")
                    case .failure(let returnedError):
                        let decodedError = returnedError as! OAuthClientError
                        switch decodedError {
                        case .errorReadingTokenFromStorage(_):
                            expect.fulfill()
                        default:
                            XCTFail("Wrong error type")
                        }
                    }
                }
            case .failure(_):
                XCTFail("Token not stored")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testTokensAreClearedWhenURLChanges() throws {
        let _ = keychain.remove(withKey: "password")
        let _ = keychain.remove(withKey: "client")

        let jsonData = TestStrings.oAuthTokenResponseExpiredWithRefresh.data(using: .utf8)

        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        try keychain.add(tokenToStore, withKey: "password")
        try keychain.add(tokenToStore, withKey: "client")

        XCTAssertEqual(keychain.keychainItems.count, 2)

        let passwordToken: OAuthAccessToken? = try? keychain.read(withKey: "password")
        let clientToken: OAuthAccessToken? = try? keychain.read(withKey: "client")

        XCTAssertNotNil(passwordToken)
        XCTAssertNotNil(clientToken)


        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)

        let _ = OAuthClient(session: urlSession,
                             keychain: keychain,
                             connectionBuilder: stagingConnectionBuilder)

        let newPasswordToken: OAuthAccessToken? = try? keychain.read(withKey: "password")
        let newClientToken: OAuthAccessToken? = try? keychain.read(withKey: "client")

        XCTAssertNil(newPasswordToken)
        XCTAssertNil(newClientToken)

    }

    func testTokensAreNotClearedWhenURLIsNotChanged() throws {
        let _ = keychain.remove(withKey: "password")
        let _ = keychain.remove(withKey: "client")

        let jsonData = TestStrings.oAuthTokenResponseExpiredWithRefresh.data(using: .utf8)

        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        try keychain.add(tokenToStore, withKey: "password")
        try keychain.add(tokenToStore, withKey: "client")

        XCTAssertEqual(keychain.keychainItems.count, 2)

        let passwordToken: OAuthAccessToken? = try? keychain.read(withKey: "password")
        let clientToken: OAuthAccessToken? = try? keychain.read(withKey: "client")

        XCTAssertNotNil(passwordToken)
        XCTAssertNotNil(clientToken)


        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)

        let _ = OAuthClient(session: urlSession,
                             keychain: keychain,
                             connectionBuilder: connectionBuilder)

        let newPasswordToken: OAuthAccessToken? = try? keychain.read(withKey: "password")
        let newClientToken: OAuthAccessToken? = try? keychain.read(withKey: "client")

        XCTAssertNotNil(newPasswordToken)
        XCTAssertNotNil(newClientToken)

        XCTAssertEqual(passwordToken?.accessToken, newPasswordToken?.accessToken)
        XCTAssertEqual(clientToken?.accessToken, newClientToken?.accessToken)
    }

    func testClearTokensActuallyClearsTokens() throws {
        let _ = keychain.remove(withKey: "password")
        let _ = keychain.remove(withKey: "client")

        let jsonData = TestStrings.oAuthTokenResponseExpiredWithRefresh.data(using: .utf8)

        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        try keychain.add(tokenToStore, withKey: "password")
        try keychain.add(tokenToStore, withKey: "client")

        XCTAssertEqual(keychain.keychainItems.count, 2)

        let passwordToken: OAuthAccessToken? = try? keychain.read(withKey: "password")
        let clientToken: OAuthAccessToken? = try? keychain.read(withKey: "client")

        XCTAssertNotNil(passwordToken)
        XCTAssertNotNil(clientToken)

        client.clearTokens()

        let clearedPasswordToken: OAuthAccessToken? = try? keychain.read(withKey: "password")
        let clearedClientToken: OAuthAccessToken? = try? keychain.read(withKey: "client")

        XCTAssertNil(clearedClientToken)
        XCTAssertNil(clearedPasswordToken)

        XCTAssertEqual(keychain.keychainItems.count, 0)
    }
    
    func tesTokenStoredCorrectly() throws {
        let expect = expectation(description: "token is stored correctly")
        let jsonData = TestStrings.oAuthTokenResponse.data(using: .utf8)
        let tokenToStore = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)
        client.updateStoredToken(token: tokenToStore, storageKey: "password"){ (result) in
            switch result {
            case .success(let ok):
                XCTAssertEqual(ok, true)
                expect.fulfill()
            case .failure(_):
                XCTFail("expecting success - got error")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

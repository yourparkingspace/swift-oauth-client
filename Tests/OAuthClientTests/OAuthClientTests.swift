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

    let connection = OAuthServerConnection(url: URL(string: "https://test.com")!,
                                           clientID: "1",
                                           clientSecret: "abcdef")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)

        client = OAuthClient(session: urlSession,
                             connection: connection,
                             keychain: keychain)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        keychainHelper.remove(withKey: OAuthGrantType.clientCredentials.storageKey)
        keychainHelper.remove(withKey: OAuthGrantType.password("", "").storageKey)
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
        let failureClient = OAuthClient(session: urlSession, connection: connection, keychain: failingKeychain)

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
}

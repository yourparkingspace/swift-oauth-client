//
//  OAuthGrantTypeTests.swift
//  OAuthClientTests
//
//  Created by Jack Nicholson Colley on 19/04/2021.
//

import XCTest
import OAuthClient

class OAuthGrantTypeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClientCredentialsHasCorrectParams() {

        let grantType = OAuthGrantType.clientCredentials

        let params = grantType.params

        XCTAssertEqual(params["grant_type"], "client_credentials")

        XCTAssertEqual(params.count, 1)
    }

    func testPasswordGrantHasCorrectParams() {
        let grantType = OAuthGrantType.password("test@test.com", "Testing1234")

        let params = grantType.params

        XCTAssertEqual(params["grant_type"], "password")
        XCTAssertEqual(params["username"], "test@test.com")
        XCTAssertEqual(params["password"], "Testing1234")
        XCTAssertEqual(params.count, 3)
    }

    func testRefreshGrantHasCorrectParams() {
        let grantType = OAuthGrantType.refresh("abcdef1234")

        let params = grantType.params

        XCTAssertEqual(params["grant_type"], "refresh_token")
        XCTAssertEqual(params["refresh_token"], "abcdef1234")
        XCTAssertEqual(params.count, 2)
    }

    func testCustomDefinedGrantTypeHasCorrectParams() {
        var customParams = [String: String]()
        customParams["param1"] = "param1"
        customParams["param2"] = "param2"

        let grantType = OAuthGrantType.custom("custom", customParams)

        let params = grantType.params

        XCTAssertEqual(params["grant_type"], "custom")
        XCTAssertEqual(params["param1"], "param1")
        XCTAssertEqual(params["param2"], "param2")
        XCTAssertEqual(params.count, 3)
    }

    func testStorageKeyProperty() {
        let clientCredentialsGrantType = OAuthGrantType.clientCredentials
        XCTAssertEqual(clientCredentialsGrantType.storageKey, "client")

        let passwordGrantType = OAuthGrantType.password("", "")
        XCTAssertEqual(passwordGrantType.storageKey, "password")


        let refreshGrantType = OAuthGrantType.refresh("")
        XCTAssertEqual(refreshGrantType.storageKey, "password")

        let customGrantType = OAuthGrantType.custom("", [:])
        XCTAssertEqual(customGrantType.storageKey, "password")
    }
}

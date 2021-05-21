//
//  OAuthAccessTokenTests.swift
//  OAuthClientTests
//
//  Created by Jack Nicholson Colley on 19/04/2021.
//

import XCTest
import OAuthClient

class OAuthAccessTokenTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAccessTokenResponseCanBeParsed() throws {
        let jsonData = TestStrings.oAuthTokenResponse.data(using: .utf8)

        let response = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        XCTAssertNotNil(response.refreshToken)
    }

    func testAccessTokenResponseCanBeParsedWhenRefreshTokenIsNotPresent() throws {
        let jsonData = TestStrings.oAuthTokenResponseNoRefresh.data(using: .utf8)

        let response = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        XCTAssertNil(response.refreshToken)
    }

    func testIsExpiredIsTrueWhenTokenIsExpired() throws {
        let jsonData = TestStrings.oAuthTokenResponseExpired.data(using: .utf8)

        let response = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        XCTAssertTrue(response.isExpired())
    }

    func testIsExpiredIsFalseWhenTokenIsNotExpired() throws {
        let jsonData = TestStrings.oAuthTokenResponse.data(using: .utf8)

        let response = try JSONDecoder().decode(OAuthAccessToken.self, from: jsonData!)

        XCTAssertFalse(response.isExpired())
    }

    func testManualInitSetsCorrectValues() {
        let accessToken = "abc123"
        let tokenType = "Bearer"
        let expiresAt = Date().addingTimeInterval(3600)
        let refreshToken = "def456"

        let token = OAuthAccessToken(accessToken: accessToken,
                                           tokenType: tokenType,
                                           expiresAt: expiresAt,
                                           refreshToken: refreshToken)

        XCTAssertEqual(token.accessToken, accessToken)
        XCTAssertEqual(token.tokenType, tokenType)
        XCTAssertEqual(token.expiresAt, expiresAt)
        XCTAssertEqual(token.refreshToken, refreshToken)
    }
}

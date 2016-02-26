//
//  EncodingDecodingTests.swift
//  Vinyl
//
//  Created by Ruben Roques on 26/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import XCTest
@testable import Vinyl

class EncodingDecodingTests: XCTestCase {

    func test_textBodyEncoding() {

        let headers = ["Content-Type":"text/plain"]

        let bodyPlainText = "BodyData"
        let bodyData = (bodyPlainText as NSString).dataUsingEncoding(NSUTF8StringEncoding)

        if let encodedBody = encodeBody(bodyData, headers: headers) as? String {
            XCTAssertEqual(bodyPlainText, encodedBody)
        } else {
            XCTFail()
        }
    }

    func test_textBodyDecoding() {

        let headers = ["Content-Type":"text/plain"]

        let bodyPlainText = "BodyData"
        let bodyData = (bodyPlainText as NSString).dataUsingEncoding(NSUTF8StringEncoding)

        if let encodedBodyData = decodeBody(bodyPlainText, headers: headers) {
            XCTAssertEqual(bodyData, encodedBodyData)
        } else {
            XCTFail()
        }
    }

    func test_textBodyDecodingWithoutContentType() {

        let bodyPlainText = "BodyData"
        let bodyData = (bodyPlainText as NSString).dataUsingEncoding(NSUTF8StringEncoding)

        if let encodedBodyData = decodeBody(bodyPlainText, headers: [:]) {
            XCTAssertEqual(bodyData, encodedBodyData)
        } else {
            XCTFail()
        }
    }

    func test_nilBodyEncoding() {
        XCTAssertNil(encodeBody(.None, headers: [:]))
        XCTAssertNil(encodeBody(.None, headers: ["Content-Type":"text/plain"]))

        let bodyData = ("BodyData" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        XCTAssertNil(encodeBody(bodyData, headers: [:]))
    }

    func test_nilBodyDecoding() {

        XCTAssertNil(decodeBody(.None, headers: [:]))
        let bodyData = ("BodyData" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        XCTAssertNil(decodeBody(bodyData, headers: [:]))

    }
}

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

    func test_nilBodyEncoding() {
        XCTAssertNil(encodeBody(.None, headers: [:]))
        XCTAssertNil(encodeBody(.None, headers: ["Content-Type":"text/"]))

        let bodyData = ("BodyData" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        XCTAssertNil(encodeBody(bodyData, headers: [:]))
    }

    func test_nilBodyDecoding() {

        XCTAssertNil(decodeBody(.None, headers: [:]))
        let bodyData = ("BodyData" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        XCTAssertNil(decodeBody(bodyData, headers: [:]))

    }
}

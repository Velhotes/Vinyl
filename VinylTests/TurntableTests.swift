//
//  TurntableTests.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import XCTest
@testable import Vinyl

class TurntableTests: XCTestCase {

    func test_BasicVinyl() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }

        let turnatable = Turntable(vinylName: "Basic", bundle: NSBundle(forClass: TurntableTests.self))
        let request = NSURLRequest(URL: NSURL(string: "http://api.test.com")!)
        
        turnatable.dataTaskWithRequest(request) { (data, response, anError) in
            
            XCTAssertNil(anError)
            XCTAssertNil(data)

            XCTAssertEqual(response!.URL!.absoluteString, "http://api.test.com")
            expectation.fulfill()
        }
    }
}

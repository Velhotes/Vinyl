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
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test.com")
            XCTAssertEqual(httpResponse.statusCode, 200)
            expectation.fulfill()
        }
    }
    
    func test_BasicVinyl_with2Songs() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turnatable = Turntable(vinylName: "Basic_2_Songs", bundle: NSBundle(forClass: TurntableTests.self))
        
        let request1 = NSURLRequest(URL: NSURL(string: "http://api.test1.com")!)
        let request2 = NSURLRequest(URL: NSURL(string: "http://api.test2.com")!)

        var numberOfCalls = 0
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            switch numberOfCalls {
            case 0:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test1.com")
                numberOfCalls += 1
            case 1:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test2.com")
                expectation.fulfill()
            default: break
            }
        }
        
        turnatable.dataTaskWithRequest(request1, completionHandler: checker)
        turnatable.dataTaskWithRequest(request2, completionHandler: checker)
    }
    
    func test_BasicVinyl_with2Songs_andDifferentMethods() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turnatable = Turntable(vinylName: "Basic_2_Songs", bundle: NSBundle(forClass: TurntableTests.self), requestMatcherRegistry: RequestMatcherRegistry(types: [.URL]))
        
        let request1 = NSMutableURLRequest(URL: NSURL(string: "http://api.test1.com")!)
        request1.HTTPMethod = "POST"
        
        let request2 = NSMutableURLRequest(URL: NSURL(string: "http://api.test2.com")!)
        request2.HTTPMethod = "POST"
        
        var numberOfCalls = 0
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            switch numberOfCalls {
            case 0:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test1.com")
                numberOfCalls += 1
            case 1:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test2.com")
                expectation.fulfill()
            default: break
            }
        }
        
        turnatable.dataTaskWithRequest(request1, completionHandler: checker)
        turnatable.dataTaskWithRequest(request2, completionHandler: checker)
    }
}

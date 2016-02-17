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
    
    func test_Vinyl_single() {
        
        let turnatable = Turntable(vinylName: "vinyl_single", bundle: NSBundle(forClass: TurntableTests.self))
        
        singleCallTest(turnatable)
    }
    
    func test_DVR_single() {

        let turnatable = Turntable(cassetteName: "dvr_single", bundle: NSBundle(forClass: TurntableTests.self))
        
        singleCallTest(turnatable)
    }
    
    func test_Vinyl_multiple() {
        
        let turnatable = Turntable(vinylName: "vinyl_multiple", bundle: NSBundle(forClass: TurntableTests.self))
        
        multipleCallTest(turnatable)
    }
    
    func test_DVR_multiple() {
        
        let turnatable = Turntable(cassetteName: "dvr_multiple", bundle: NSBundle(forClass: TurntableTests.self))
        
        multipleCallTest(turnatable)
    }
    
    func test_Vinyl_multiple_differentMethods() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turnatable = Turntable(
            vinylName: "vinyl_multiple",
            bundle: NSBundle(forClass: TurntableTests.self),
            requestMatcherTypes: [.URL])
        
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
        
        turnatable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
    }
    
    //MARK: Aux methods
    
    private func singleCallTest(turnatable: Turntable) {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let request = NSURLRequest(URL: NSURL(string: "http://api.test.com")!)
        
        turnatable.dataTaskWithRequest(request) { (data, response, anError) in
            
            XCTAssertNil(anError)
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            let body = "hello".dataUsingEncoding(NSUTF8StringEncoding)!
                        
            XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test.com")
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertTrue(data!.isEqualToData(body))
            XCTAssertNotNil(httpResponse.allHeaderFields)
            
            expectation.fulfill()
            }.resume()
    }
    
    private func multipleCallTest(turnatable: Turntable) {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
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
        
        turnatable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
    }
}

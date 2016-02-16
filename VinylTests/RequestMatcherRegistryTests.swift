//
//  RequestMatcherRegistryTests.swift
//  Vinyl
//
//  Created by David Rodrigues on 16/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import XCTest
@testable import Vinyl

class RequestMatcherRegistryTests: XCTestCase {
    
    func test_Match_byPath_withSamePath() {
        
        let registry = RequestMatcherRegistry(types: [.Path])
        
        let aRequest = NSURLRequest(URL: NSURL(string: "http://hostname1/some/path?param1=ab&param2=de")!)
        let anotherRequest = NSURLRequest(URL: NSURL(string: "https://hostname2/some/path")!)
        
        XCTAssertTrue(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byPath_withDifferentPath() {
        
        let registry = RequestMatcherRegistry(types: [.Path])
        
        let aRequest = NSURLRequest(URL: NSURL(string: "http://hostname1/some/path?param1=ab&param2=de")!)
        let anotherRequest = NSURLRequest(URL: NSURL(string: "https://hostname2/some/path/another/one")!)
        
        XCTAssertFalse(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byQuery_Ordered() {
        
        let registry = RequestMatcherRegistry(types: [.Query])
        
        let aRequest = NSURLRequest(URL: NSURL(string: "http://hostname1/some/path?param1=ab&param2=de")!)
        let anotherRequest = NSURLRequest(URL: NSURL(string: "http://hostname1/some/path?param1=ab&param2=de")!)
        
        XCTAssertTrue(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }

    func test_Match_byQuery_Ordered_DifferentURL() {
        
        let registry = RequestMatcherRegistry(types: [.Query])
        
        let aRequest = NSURLRequest(URL: NSURL(string: "http://hostname1/some/path?param1=ab&param2=de")!)
        let anotherRequest = NSURLRequest(URL: NSURL(string: "http://hostname2/another/path?param1=ab&param2=de")!)
        
        XCTAssertTrue(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byQuery_Unordered() {
        
        let registry = RequestMatcherRegistry(types: [.Query])
        
        let aRequest = NSURLRequest(URL: NSURL(string: "http://hostname/some/path?param1=ab&param2=de")!)
        let anotherRequest = NSURLRequest(URL: NSURL(string: "http://hostname/some/path?param2=de&param1=ab")!)
        
        XCTAssertTrue(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byQuery_withDifferentQuery() {
        
        let registry = RequestMatcherRegistry(types: [.Query])
        
        let aRequest = NSURLRequest(URL: NSURL(string: "http://hostname/some/path?param1=ab&param2=de&param3=pt")!)
        let anotherRequest = NSURLRequest(URL: NSURL(string: "http://hostname/some/path?param2=de&param1=ab")!)
        
        XCTAssertFalse(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byHeader_withSameHeader() {
        
        let registry = RequestMatcherRegistry(types: [.Headers])
        
        let commonHeader = ["header" : "common", "awesomeness": "max"]
        
        let aRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        aRequest.allHTTPHeaderFields = commonHeader
        
        let anotherRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        anotherRequest.allHTTPHeaderFields = commonHeader
        
        XCTAssertTrue(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byHeader_withSameHeader_Capitalized() {
        
        let registry = RequestMatcherRegistry(types: [.Headers])
        
        let aRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        aRequest.allHTTPHeaderFields = ["header" : "common", "awesomeness": "max"]
        
        let anotherRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        anotherRequest.allHTTPHeaderFields = ["HEADER" : "common", "awesomeness": "MAX"]
        
        XCTAssertTrue(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }

    
    func test_Match_byHeader_withDifferentHeader() {
        
        let registry = RequestMatcherRegistry(types: [.Headers])
        
        let aRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        aRequest.allHTTPHeaderFields = ["header" : "aRequest", "awesomeness": "max"]
        
        let anotherRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        anotherRequest.allHTTPHeaderFields = ["header" : "anotherRequest", "awesomeness": "min"]
        
        XCTAssertFalse(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byBody_withSameBody() {
        
        let registry = RequestMatcherRegistry(types: [.Body])
        
        let commonData = "Hello World".dataUsingEncoding(NSUTF8StringEncoding)
        
        let aRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        aRequest.HTTPBody = commonData
        
        let anotherRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        anotherRequest.HTTPBody = commonData
        
        XCTAssertTrue(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byBody_withNilBody() {
        
        let registry = RequestMatcherRegistry(types: [.Body])
        
        let aRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        let anotherRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        
        XCTAssertTrue(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
    
    func test_Match_byBody_withDifferentBody() {
        
        let registry = RequestMatcherRegistry(types: [.Body])
        
        let aRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        aRequest.HTTPBody =  "Foo".dataUsingEncoding(NSUTF8StringEncoding)

        let anotherRequest = NSMutableURLRequest(URL: NSURL(string: "http://hostname/some/path")!)
        anotherRequest.HTTPBody =  "Bar".dataUsingEncoding(NSUTF8StringEncoding)

        XCTAssertFalse(registry.matchableRequests(aRequest, anotherRequest: anotherRequest))
    }
}

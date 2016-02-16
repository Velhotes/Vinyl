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
}

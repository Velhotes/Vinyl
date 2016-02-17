//
//  VinylTests.swift
//  Vinyl
//
//  Created by Rui Peres on 17/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import XCTest
@testable import Vinyl

class VinylTests: XCTestCase {

    func test_badVinylCreation() {
        
        let vinyl = VinylFactory.createBadVinyl(NSURL(string: "http://badRecord.com")!, statusCode: 400)
        
        let track = vinyl.tracks[0]
        
        XCTAssertTrue(vinyl.tracks.count == 1)
        XCTAssertTrue(track.response.urlResponse.statusCode == 400)
        XCTAssertTrue(track.response.urlResponse.URL?.absoluteString == "http://badRecord.com")
        XCTAssertTrue(track.request?.URL?.absoluteString == "http://badRecord.com")
    }
    
    func test_badVinylCreation_withError() {
        
        let error = NSError(domain: "Test Domain", code: 1, userInfo: nil)
        let vinyl = VinylFactory.createBadVinyl(NSURL(string: "http://badRecord.com")!, statusCode: 400, error: error)
        
        let track = vinyl.tracks[0]
        
        XCTAssertTrue(vinyl.tracks.count == 1)
        XCTAssertTrue(track.response.urlResponse.statusCode == 400)
        XCTAssertTrue(track.response.error == error)
        XCTAssertTrue(track.response.urlResponse.URL?.absoluteString == "http://badRecord.com")
        XCTAssertTrue(track.request?.URL?.absoluteString == "http://badRecord.com")
    }

    func test_AwesomeVinylCreation() {
        
        let data = "Hello World".dataUsingEncoding(NSUTF8StringEncoding)!
        let headers = ["awesomeness": "max"]
        
        let vinyl = VinylFactory.createVinyl(NSURL(string: "http://feelGoodINC.com")!, body: data, headers: headers)
        
        let track = vinyl.tracks[0]
        
        print(track.response.urlResponse.allHeaderFields)
        
        XCTAssertTrue(vinyl.tracks.count == 1)
        XCTAssertTrue(track.response.urlResponse.statusCode == 200)
        XCTAssertTrue(track.response.body!.isEqualToData(data))
        XCTAssertTrue(track.response.urlResponse.allHeaderFields as! [String: String] == headers)
        XCTAssertTrue(track.response.urlResponse.URL?.absoluteString == "http://feelGoodINC.com")
        XCTAssertTrue(track.request?.URL?.absoluteString == "http://feelGoodINC.com")
    }
}

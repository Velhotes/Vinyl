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
}
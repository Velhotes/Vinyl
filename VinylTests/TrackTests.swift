//
//  TrackTests.swift
//  Vinyl
//
//  Created by Rui Peres on 17/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import XCTest
@testable import Vinyl
import SwiftCheck

class TrackTests: XCTestCase {
    func testProperties() {
        property("Bad tracks contain no body") <- forAllNoShrink(urlStringGen) { url in
            let track = TrackFactory.createBadTrack(NSURL(string: url)!, statusCode: 400)
            return track.response.urlResponse.statusCode == 400
                && track.response.urlResponse.URL?.absoluteString == url
                && track.request.URL?.absoluteString == url
                && track.response.body == nil 
        }
        
        property("Bad tracks created with an error reflect that error") <- forAllNoShrink(urlStringGen) { url in
            return forAll { (domain : String, code : Positive<Int>) in
                let error = NSError(domain: domain, code: code.getPositive, userInfo: nil)
                let track = TrackFactory.createBadTrack(NSURL(string: url)!, statusCode: code.getPositive, error: error)
                return track.response.urlResponse.statusCode == code.getPositive
                    && track.response.error == error
                    && track.response.urlResponse.URL?.absoluteString == url
                    && track.request.URL?.absoluteString == url
                    && track.response.body == nil 
            }
        }
        
        property("Well made tracks are well made") <- forAllNoShrink(
              urlStringGen
            , String.arbitrary
            , HTTPHeaders.arbitrary
        ) { (url, body, headers) in
            let data = body.dataUsingEncoding(NSUTF8StringEncoding)!
            let track = TrackFactory.createValidTrack(NSURL(string: url)!, body: data, headers: headers)
            
            return track.response.urlResponse.statusCode == 200
                && track.response.body!.isEqualToData(data)
                && track.response.urlResponse.allHeaderFields as! HTTPHeaders == headers
                && track.response.urlResponse.URL?.absoluteString == url
                && track.request.URL?.absoluteString == url
        }
    }
}

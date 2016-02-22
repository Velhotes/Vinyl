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
                
                return isValidTrack(track, data: data, headers: headers, url: url)
        }
        
        property("Well made tracks for base64") <- forAllNoShrink(
            urlStringGen
            , String.arbitrary
            , HTTPHeaders.arbitrary
            ) { (url, body, headers) in
                
                guard let data = NSData(base64EncodedString: body, options: .IgnoreUnknownCharacters) else { return true }
                let track = TrackFactory.createValidTrackFromBase64(NSURL(string: url)!, bodyString:body, headers: headers)
                
                return isValidTrack(track, data: data, headers: headers, url: url)
        }
        
        property("Well made tracks for utf8") <- forAllNoShrink(
            urlStringGen
            , String.arbitrary
            , HTTPHeaders.arbitrary
            ) { (url, body, headers) in
                
                guard let data = body.dataUsingEncoding(NSUTF8StringEncoding) else { return true}
                let track = TrackFactory.createValidTrackFromUTF8(NSURL(string: url)!, bodyString:body, headers: headers)
                
                return isValidTrack(track, data: data, headers: headers, url: url)
        }
        
        property("Well made tracks for JSON") <- forAllNoShrink(
            urlStringGen
            , basicJSONDic
            , HTTPHeaders.arbitrary
            ) { (url, body, headers) in
                
                print(basicJSONDic)
                guard let data = try? NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted) else { return true}
                let track = TrackFactory.createValidTrackFromJSON(NSURL(string: url)!, json:body, headers: headers)
                
                return isValidTrack(track, data: data, headers: headers, url: url)
        }
    }   
}

func isValidTrack(track: Track, data: NSData, headers: HTTPHeaders, url: String) -> Bool {
    
    return track.response.urlResponse.statusCode == 200
        && track.response.body!.isEqualToData(data)
        && track.response.urlResponse.allHeaderFields as! HTTPHeaders == headers
        && track.response.urlResponse.URL?.absoluteString == url
        && track.request.URL?.absoluteString == url
}

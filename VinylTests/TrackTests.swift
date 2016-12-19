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
            let track = TrackFactory.createBadTrack(URL(string: url)!, statusCode: 400)
            return track.response.urlResponse?.statusCode == 400
                && track.response.urlResponse?.url?.absoluteString == url
                && track.request.url?.absoluteString == url
                && track.response.body == nil
        }
        
        property("Bad tracks created with an error reflect that error") <- forAllNoShrink(urlStringGen) { url in
            return forAll { (domain : String, code : Positive<Int>) in
                let error = NSError(domain: domain, code: code.getPositive, userInfo: nil)
                let track = TrackFactory.createBadTrack(URL(string: url)!, statusCode: code.getPositive, error: error)
                
                return track.response.urlResponse?.statusCode == code.getPositive
                    && track.response.error?.localizedDescription == error.localizedDescription
                    && track.response.urlResponse?.url?.absoluteString == url
                    && track.request.url?.absoluteString == url
                    && track.response.body == nil
            }
        }

        property("Error tracks created without a status code") <- forAllNoShrink(urlStringGen) { url in
            return forAll { (domain : String, code : Positive<Int>) in
                let error = NSError(domain: domain, code: code.getPositive, userInfo: nil)
                let track = TrackFactory.createErrorTrack(URL(string: url)!, error: error)

                return track.response.urlResponse == .none
                    && track.response.error?.localizedDescription == error.localizedDescription
                    && track.request.url?.absoluteString == url
                    && track.response.body == nil
            }
        }
        
        property("Well made tracks are well made") <- forAllNoShrink(
            urlStringGen
            , String.arbitrary
            , HTTPHeaders.arbitrary
            ) { (url, body, headers) in
                let data = body.data(using: .utf8)!
                let track = TrackFactory.createValidTrack(URL(string: url)!, body: data, headers: headers)
                
                return isValidTrack(track, data: data, headers: headers, url: url)
        }
        
        property("Well made tracks for base64") <- forAllNoShrink(
            urlStringGen
            , String.arbitrary
            , HTTPHeaders.arbitrary
            ) { (url, body, headers) in
                
                guard let data = Data(base64Encoded: body, options: .ignoreUnknownCharacters) else { return true }
                let track = TrackFactory.createValidTrackFromBase64(URL(string: url)!, bodyString:body, headers: headers)
                
                return isValidTrack(track, data: data, headers: headers, url: url)
        }
        
        property("Well made tracks for utf8") <- forAllNoShrink(
            urlStringGen
            , String.arbitrary
            , HTTPHeaders.arbitrary
            ) { (url, body, headers) in
                
                guard let data = body.data(using: .utf8) else { return true}
                let track = TrackFactory.createValidTrackFromUTF8(URL(string: url)!, bodyString:body, headers: headers)
                
                return isValidTrack(track, data: data, headers: headers, url: url)
        }
        
        property("Well made tracks for JSON") <- forAllNoShrink(
            urlStringGen
            , basicJSONDic
            , HTTPHeaders.arbitrary
            ) { (url, body, headers) in
                
                guard let data = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) else { return true}
                let track = TrackFactory.createValidTrackFromJSON(URL(string: url)!, json:body, headers: headers)
                
                return isValidTrack(track, data: data, headers: headers, url: url)
        }
    }
}

func isValidTrack(_ track: Track, data: Data, headers: HTTPHeaders, url: String) -> Bool {
    
    return track.response.urlResponse?.statusCode == 200
        && (track.response.body! == data)
        && track.response.urlResponse?.allHeaderFields as! HTTPHeaders == headers
        && track.response.urlResponse?.url?.absoluteString == url
        && track.request.url?.absoluteString == url
}

//
//  RequestMatcherRegistryTests.swift
//  Vinyl
//
//  Created by David Rodrigues on 16/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import XCTest
@testable import Vinyl
import SwiftCheck

class RequestMatcherRegistryTests: XCTestCase {
    func testProperties() {
        property("Requests with identical paths and query parameters should match") <- forAllNoShrink(
              Gen<RequestMatcherType>.fromElementsOf([RequestMatcherType.Path, .Query, .Body])
            , urlStringGen
            , urlPathGen
            , pathParameterGen
            , Optional<String>.arbitrary
        ) { (type, url, path, params, body) in
            let registry = RequestMatcherRegistry(types: [type])
            let commonData = body?.dataUsingEncoding(NSUTF8StringEncoding)
            
            let aRequest = NSMutableURLRequest(URL: NSURL(string: url + path + params )!)			
            aRequest.HTTPBody = commonData
            
            let anotherRequest = NSMutableURLRequest(URL: NSURL(string: url + path + params)!)
            anotherRequest.HTTPBody = commonData
            
            return registry.matchableRequests(aRequest, anotherRequest: anotherRequest)
        }
        
        property("Requests with identical headers should match") <- forAllNoShrink(
              urlStringGen
            , HTTPHeaders.arbitrary
        ) { (url, headers) in
            let registry = RequestMatcherRegistry(types: [.Headers])
            
            let aRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
            aRequest.allHTTPHeaderFields = headers
            
            let anotherRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
            anotherRequest.allHTTPHeaderFields = headers
            
            return registry.matchableRequests(aRequest, anotherRequest: anotherRequest)
        }
        
        property("Requests with mixed values shouldn't match") <- forAllNoShrink(
              urlStringGen
            , Positive<Int>.arbitrary
        ) { (url, size) in
            return forAllNoShrink(
                  lowerStringGen.proliferateSized(size.getPositive)
                , lowerStringGen.proliferateSized(size.getPositive)
            ) { (keys, vals) in
                let headers = HTTPHeaders(zip(keys, vals.sort(>)))
                let upperHeaders = HTTPHeaders(zip(keys, vals.sort(<)))
                let registry = RequestMatcherRegistry(types: [.Headers])
                
                let aRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
                aRequest.allHTTPHeaderFields = headers
                
                let anotherRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
                anotherRequest.allHTTPHeaderFields = upperHeaders
                
                return registry.matchableRequests(aRequest, anotherRequest: anotherRequest)
            }
        }.expectFailure
        
        property("Requests with mix-case headers should match") <- forAllNoShrink(
              urlStringGen
            , Positive<Int>.arbitrary
        ) { (url, size) in
            return forAllNoShrink(
                  lowerStringGen.proliferateSized(size.getPositive)
                , lowerStringGen.proliferateSized(size.getPositive)
            ) { (keys, vals) in
                let headers = HTTPHeaders(zip(keys, vals))
                let upperHeaders = HTTPHeaders(headers.map { (l, r) in (l.uppercaseString, r.uppercaseString) })
                let registry = RequestMatcherRegistry(types: [.Headers])
                
                let aRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
                aRequest.allHTTPHeaderFields = headers
                
                let anotherRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
                anotherRequest.allHTTPHeaderFields = upperHeaders
                
                return registry.matchableRequests(aRequest, anotherRequest: anotherRequest)
            }
        }
    }
}

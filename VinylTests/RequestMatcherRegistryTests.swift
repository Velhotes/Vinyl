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

extension Dictionary {
    init<S : Sequence>(_ pairs : S)  {
        self.init()        
        var g = pairs.makeIterator()
        while let (k, v) : (Key, Value) = g.next() as! (Key, Value)? {
            self[k] = v
        }
    }
}


class RequestMatcherRegistryTests: XCTestCase {
    func testProperties() {
        property("Requests with identical paths and query parameters should match") <- forAllNoShrink(
              Gen<RequestMatcherType>.fromElements(of: [RequestMatcherType.path, .query, .body])
            , urlStringGen
            , urlPathGen
            , pathParameterGen
            , Optional<String>.arbitrary
        ) { (type, url, path, params, body) in
            let registry = RequestMatcherRegistry(types: [type])
            let commonData = body?.data(using: .utf8)
            
            var aRequest = URLRequest(url: URL(string: url + path + params )!)
            aRequest.httpBody = commonData
            
            var anotherRequest = URLRequest(url: URL(string: url + path + params)!)
            anotherRequest.httpBody = commonData
            
            return registry.matchableRequests(request: aRequest, with: anotherRequest)
        }
        
        property("Requests with identical headers should match") <- forAllNoShrink(
              urlStringGen
            , HTTPHeaders.arbitrary
        ) { (url, headers) in
            let registry = RequestMatcherRegistry(types: [.headers])
            
            var aRequest = URLRequest(url: URL(string: url)!)
            aRequest.allHTTPHeaderFields = headers
            
            var anotherRequest = URLRequest(url: URL(string: url)!)
            anotherRequest.allHTTPHeaderFields = headers
            
            return registry.matchableRequests(request: aRequest, with: anotherRequest)
        }
        
        property("Requests with mixed values shouldn't match") <- forAllNoShrink(
              urlStringGen
            , Positive<Int>.arbitrary
        ) { (url, size) in
            return forAllNoShrink(
                  lowerStringGen.proliferate(withSize: size.getPositive)
                , lowerStringGen.proliferate(withSize: size.getPositive)
            ) { (keys, vals) in
                let headers = HTTPHeaders(zip(keys, vals.sorted { $0.caseInsensitiveCompare($1) == .orderedDescending }))
                let upperHeaders = HTTPHeaders(zip(keys, vals.sorted()))
                
                let registry = RequestMatcherRegistry(types: [.headers])
                
                var aRequest = URLRequest(url: URL(string: url)!)
                aRequest.allHTTPHeaderFields = headers
                
                var anotherRequest = URLRequest(url: URL(string: url)!)
                anotherRequest.allHTTPHeaderFields = upperHeaders
                
                return registry.matchableRequests(request: aRequest, with: anotherRequest)
            }
        }.expectFailure
        
        property("Requests with mix-case headers should match") <- forAllNoShrink(
              urlStringGen
            , Positive<Int>.arbitrary
        ) { (url, size) in
            return forAllNoShrink(
                  lowerStringGen.proliferate(withSize: size.getPositive)
                , lowerStringGen.proliferate(withSize: size.getPositive)
            ) { (keys, vals) in
                let headers = HTTPHeaders(zip(keys, vals))
                let upperHeaders = HTTPHeaders(headers.map { (l, r) in (l.uppercased(), r.uppercased()) })
                let registry = RequestMatcherRegistry(types: [.headers])
                
                var aRequest = URLRequest(url: URL(string: url)!)
                aRequest.allHTTPHeaderFields = headers
                
                var anotherRequest = URLRequest(url: URL(string: url)!)
                anotherRequest.allHTTPHeaderFields = upperHeaders
                
                return registry.matchableRequests(request: aRequest, with: anotherRequest)
            }
        }
    }
}

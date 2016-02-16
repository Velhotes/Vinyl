//
//  Track.swift
//  Vinyl
//
//  Created by David Rodrigues on 14/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

typealias EncodedObject = [String : AnyObject]
typealias HTTPHeaders = [String : String]

typealias Request = NSURLRequest

struct Response {
    let urlResponse: NSURLResponse
    let body: NSData?
    let error: NSError?
}

struct Track {
    let request: Request
    let response: Response
}

extension Track {
    
    init(encodedTrack: EncodedObject) {
        guard
            let encodedRequest = encodedTrack["request"] as? EncodedObject,
            let encodedResponse = encodedTrack["response"] as? EncodedObject
        else {
            fatalError("request/response not found 😞 for Track: \(encodedTrack)")
        }
        
        // We're using a helper function because we cannot mutate a NSURLRequest directly
        request = Request.createWithEncodedRequest(encodedRequest)
        
        response = Response(encodedResponse: encodedResponse)
    }
}

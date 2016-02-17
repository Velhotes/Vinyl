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
    let urlResponse: NSHTTPURLResponse
    let body: NSData?
    let error: NSError?
    
    init(urlResponse: NSHTTPURLResponse, body: NSData? = nil, error: NSError? = nil) {
        self.urlResponse = urlResponse
        self.body = body
        self.error = error
    }
}

struct Track {
    let request: Request?
    let response: Response
    
    init(request: Request, response: Response) {
        self.request = request
        self.response = response
    }
    
    init(response: Response) {
        
        self.response = response
        
        guard
            let urlString = response.urlResponse.URL?.absoluteString,
            let url = NSURL(string: urlString)
        else {
            self.request = nil
            return
        }
        
        self.request = NSURLRequest(URL: url)
    }
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

struct TrackFactory {
    
    static func createTrack(url: NSURL, statusCode: Int, body: NSData? = nil, error: NSError? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        guard
            let response = NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: headers)
            else {
                fatalError("We weren't able to create the Track 😫")
        }
        
        let track = Track(response: Response(urlResponse: response, body: body, error: error))
        return track
    }
    
    static func createBadTrack(url: NSURL, statusCode: Int, error: NSError? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        return createTrack(url, statusCode: statusCode, body: nil, error: error, headers: headers)
    }
    
    static func createValidTrack(url: NSURL, body: NSData? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
    }
}

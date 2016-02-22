//
//  Track.swift
//  Vinyl
//
//  Created by David Rodrigues on 14/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

public typealias EncodedObject = [String : AnyObject]
public typealias HTTPHeaders = [String : String]

public typealias Request = NSURLRequest

public struct Track {
    let request: Request
    let response: Response
    
    init(request: Request, response: Response) {
        self.request = request
        self.response = response
    }
    
    init(response: Response) {
        
        self.response = response
        
        let urlString = response.urlResponse.URL?.absoluteString
        let url = NSURL(string: urlString!)!
        
        self.request = NSURLRequest(URL: url)
    }
}

// MARK: - Extensions

extension Track {
    
    init(encodedTrack: EncodedObject) {
        
        guard let encodedResponse = encodedTrack["response"] as? EncodedObject else {
            fatalError("request/response not found 😞 for Track: \(encodedTrack)")
        }
        
        let response = Response(encodedResponse: encodedResponse)
        
        if let encodedRequest = encodedTrack["request"] as? EncodedObject {
            
            // We're using a helper function because we cannot mutate a NSURLRequest directly
            let request = Request.createWithEncodedRequest(encodedRequest)
            
            self.init(request: request, response: response)
            
        } else {
            self.init(response: response)
        }
    }
}

extension Track: Hashable {
    
    public var hashValue: Int {
        return request.hashValue ^ response.hashValue
    }
    
}

public func ==(lhs: Track, rhs: Track) -> Bool {
    return lhs.request == rhs.request && lhs.response == rhs.response
}

// MARK: - Factory

public struct TrackFactory {
    
    public static func createTrack(url: NSURL, statusCode: Int, body: NSData? = nil, error: NSError? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        guard
            let response = NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: headers)
            else {
                fatalError("We weren't able to create the Track 😫")
        }
        
        let track = Track(response: Response(urlResponse: response, body: body, error: error))
        return track
    }
    
    public static func createBadTrack(url: NSURL, statusCode: Int, error: NSError? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        return createTrack(url, statusCode: statusCode, body: nil, error: error, headers: headers)
    }
    
    public static func createValidTrack(url: NSURL, body: NSData? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
    }
    
    public static func createValidTrackFromJSON(url: NSURL, json: AnyObject, headers: HTTPHeaders = [:]) -> Track {
        
        do {
            let body = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
        }
        catch {
            fatalError("Invalid JSON 😕\nBefore trying again check your JSON here http://jsonlint.com/ 👍")
        }
    }
    
    public static func createValidTrackFromBase64(url: NSURL, bodyString: String, headers: HTTPHeaders = [:]) -> Track {
        
        let body = NSData(base64EncodedString: bodyString, options: .IgnoreUnknownCharacters)
        return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
    }
    
    public static func createValidTrackFromUTF8(url: NSURL, bodyString: String, headers: HTTPHeaders = [:]) -> Track {
        
        let body = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
    }
}

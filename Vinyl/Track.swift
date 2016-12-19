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

public typealias Request = URLRequest

public struct Track {
    let request: Request
    let response: Response
    
    init(request: Request, response: Response) {
        self.request = request
        self.response = response
    }
    
    init(response: Response) {
        
        self.response = response
        
        let urlString = response.urlResponse?.url?.absoluteString
        let url = URL(string: urlString!)!
        
        self.request = URLRequest(url: url)
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
    
    func encodedTrack() -> EncodedObject {
        var json = EncodedObject()
        
        json["request"] = request.encodedObject() as AnyObject?
        json["response"] = response.encodedObject() as AnyObject?
        
        return json
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
    
    public static func createTrack(_ url: URL, statusCode: Int, body: Data? = nil, error: Error? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        guard
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers)
            else {
                fatalError("We weren't able to create the Track 😫")
        }
        
        let track = Track(response: Response(urlResponse: response, body: body, error: error))
        return track
    }
    
    public static func createBadTrack(_ url: URL, statusCode: Int, error: Error? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        return createTrack(url, statusCode: statusCode, body: nil, error: error, headers: headers)
    }

    public static func createErrorTrack(_ url: URL, error: Error) -> Track {

        let request = URLRequest(url: url)
        let response = Response(urlResponse: nil, body: nil, error: error)
        return Track(request: request, response: response)
    }
    
    public static func createValidTrack(_ url: URL, body: Data? = nil, headers: HTTPHeaders = [:]) -> Track {
        
        return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
    }
    
    public static func createValidTrackFromJSON(_ url: URL, json: AnyObject, headers: HTTPHeaders = [:]) -> Track {
        
        do {
            let body = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
        }
        catch {
            fatalError("Invalid JSON 😕\nBefore trying again check your JSON here http://jsonlint.com/ 👍")
        }
    }
    
    public static func createValidTrackFromBase64(_ url: URL, bodyString: String, headers: HTTPHeaders = [:]) -> Track {
        
        let body = Data(base64Encoded: bodyString, options: .ignoreUnknownCharacters)
        return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
    }
    
    public static func createValidTrackFromUTF8(_ url: URL, bodyString: String, headers: HTTPHeaders = [:]) -> Track {
        
        let body = bodyString.data(using: String.Encoding.utf8)
        return createTrack(url, statusCode: 200, body: body, error: nil, headers: headers)
    }
}

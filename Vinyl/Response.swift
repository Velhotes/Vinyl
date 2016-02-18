//
//  Response.swift
//  Vinyl
//
//  Created by David Rodrigues on 18/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

public struct Response {
   public let urlResponse: NSHTTPURLResponse
   public let body: NSData?
   public let error: NSError?
    
   public init(urlResponse: NSHTTPURLResponse, body: NSData? = nil, error: NSError? = nil) {
        self.urlResponse = urlResponse
        self.body = body
        self.error = error
    }
}

public extension Response {
    
    public init(encodedResponse: EncodedObject) {
        guard
            let urlString = encodedResponse["url"] as? String,
            let url =  NSURL(string: urlString),
            let statusCode = encodedResponse["status"] as? Int,
            let headers = encodedResponse["headers"] as? HTTPHeaders,
            let urlResponse = NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: headers)
            else {
                fatalError("key not found 😞 for Response (check url/statusCode/headers) check \n------\n\(encodedResponse)\n------\n")
        }
        
        self.init(urlResponse: urlResponse, body: decodeBody(encodedResponse["body"], headers: headers), error: nil)
    }
}

public func ==(lhs: Response, rhs: Response) -> Bool {
    return lhs.urlResponse == rhs.urlResponse && lhs.body == rhs.body && lhs.error == rhs.error
}

extension Response: Hashable {
    
    public var hashValue: Int {
        
        let body = self.body ?? ""
        let error = self.error ?? ""
        
        return "\(urlResponse.hashValue):\((body)):\(error)".hashValue
    }
    
}

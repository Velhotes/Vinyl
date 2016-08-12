//
//  NSURLRequest.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

extension NSURLRequest {
    
    class func createWithEncodedRequest(encodedRequest: EncodedObject) -> NSURLRequest {
        guard
            let urlString = encodedRequest["url"] as? String,
            let url = NSURL(string: urlString)
            else {
                fatalError("URL not found 😞 for Request: \(encodedRequest)")
        }
        
        let request = NSMutableURLRequest(URL: url)
        
        if let method = encodedRequest["method"] as? String {
            request.HTTPMethod = method
        }
        
        if let headers = encodedRequest["headers"] as? HTTPHeaders {
            request.allHTTPHeaderFields = headers
            
            if let body = decodeBody(encodedRequest["body"], headers: headers) {
                request.HTTPBody = body
            }
        }
        
        return request
    }
    
    func encodedObject() -> EncodedObject {
        var json = EncodedObject()
        
        json["url"] = URL?.absoluteString
        json["method"] = HTTPMethod
        
        if let headers = allHTTPHeaderFields {
            json["headers"] = headers
            json["body"] = encodeBody(HTTPBody, headers: headers)
        }
        
        return json
    }
}

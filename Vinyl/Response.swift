//
//  Response.swift
//  Vinyl
//
//  Created by David Rodrigues on 18/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

struct Response {
    let urlResponse: NSHTTPURLResponse?
    let body: NSData?
    let error: NSError?
    
    init(urlResponse: NSHTTPURLResponse?, body: NSData? = nil, error: NSError? = nil) {
        self.urlResponse = urlResponse
        self.body = body
        self.error = error
    }
}

extension Response {
    
    init(encodedResponse: EncodedObject) {
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
    
    func encodedObject() -> EncodedObject {
        var json = EncodedObject()
        
        if let response = urlResponse {
            json["url"] = response.URL?.absoluteString
            json["status"] = response.statusCode
            json["headers"] = response.allHeaderFields
            json["body"] = encodeBody(body, headers: response.allHeaderFields as! [String : String])
        }
        
        return json
    }
}

func ==(lhs: Response, rhs: Response) -> Bool {
    return lhs.urlResponse == rhs.urlResponse && lhs.body == rhs.body && lhs.error == rhs.error
}

extension Response: Hashable {
    
    var hashValue: Int {
        
        let body = self.body ?? ""
        let error = self.error ?? ""
        
        return "\(urlResponse?.hashValue):\((body)):\(error)".hashValue
    }    
}

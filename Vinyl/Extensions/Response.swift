//
//  Response.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

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
}

func ==(lhs: Response, rhs: Response) -> Bool {
    return lhs.urlResponse == rhs.urlResponse && lhs.body == rhs.body && lhs.error == rhs.error
}

extension Response: Hashable {
    
    var hashValue: Int {
        
        var hash = urlResponse.hashValue
        
        if let body = body {
            hash ^= body.hashValue
        }
        
        if let error = error {
            hash ^= error.hashValue
        }
        
        return hash
    }
    
}
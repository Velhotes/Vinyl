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
            let statusCode = encodedResponse["statusCode"] as? Int,
            let headers = encodedResponse["headers"] as? HTTPHeaders,
            let urlResponse = NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: headers)
            else {
                fatalError("key not found 😞 for Response (check url/statusCode/headers) \(encodedResponse)")
        }
        
        self.init(urlResponse: urlResponse, body: decodeBody(encodedResponse["body"], headers: headers), error: nil)
    }
}

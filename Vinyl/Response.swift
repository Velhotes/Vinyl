//
//  Response.swift
//  Vinyl
//
//  Created by David Rodrigues on 18/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

struct Response {
    let urlResponse: HTTPURLResponse?
    let body: Data?
    let error: Error?
    
    init(urlResponse: HTTPURLResponse?, body: Data? = nil, error: Error? = nil) {
        self.urlResponse = urlResponse
        self.body = body
        self.error = error
    }
}

extension Response {
    
    init(encodedResponse: EncodedObject) {
        guard
            let urlString = encodedResponse["url"] as? String,
            let url =  URL(string: urlString),
            let statusCode = encodedResponse["status"] as? Int,
            let headers = encodedResponse["headers"] as? HTTPHeaders,
            let urlResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers)
        else {
            fatalError("key not found 😞 for Response (check url/statusCode/headers) check \n------\n\(encodedResponse)\n------\n")
        }
        
        self.init(urlResponse: urlResponse, body: decode(body: encodedResponse["body"], headers: headers), error: nil)
    }
    
    func encodedObject() -> EncodedObject {
        var json = EncodedObject()
        
        if let response = urlResponse {
            json["url"] = response.url?.absoluteString
            json["status"] = response.statusCode
            json["headers"] = response.allHeaderFields
            json["body"] = encode(body: body, headers: response.allHeaderFields as! [String : String])
        }
        
        return json
    }
}

func ==(lhs: Response, rhs: Response) -> Bool {
    return lhs.urlResponse == rhs.urlResponse
        && lhs.body == rhs.body
        && lhs.error?._domain == rhs.error?._domain
        && lhs.error?._code   == rhs.error?._code
}

extension Response: Hashable {
    
    var hashValue: Int {        
        let body = self.body == nil ? "" : "\(self.body!)"
        let error = self.error == nil ? "" : "\(self.error!)"
        
        return "\(urlResponse?.hashValue ?? 0):\((body)):\(error)".hashValue
    }    
}

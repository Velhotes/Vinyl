//
//  EncodingDecoding.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

func encodeBody(bodyData: NSData?, headers: [String: String]) -> AnyObject? {
    
    guard
        let body = bodyData,
        let contentType = headers["Content-Type"]
        else { return nil }
    
    switch contentType {
        
    case _ where contentType.hasPrefix("text/"):
        return NSString(data: body, encoding: NSUTF8StringEncoding).map (String.init)
        
    case _ where contentType.hasPrefix("application/json"):
        return try? NSJSONSerialization.JSONObjectWithData(body, options: [])
        
    default:
        return body.base64EncodedStringWithOptions([])
    }
}

func decodeBody(bodyData: AnyObject?, headers: [String: String]) -> NSData? {
    
    guard
        let body = bodyData,
        let contentType = headers["Content-Type"]
        else { return nil }
    
    if let string = body as? String where contentType.hasPrefix("text/") {
        return string.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    if contentType.hasPrefix("application/json") {
        return try? NSJSONSerialization.dataWithJSONObject(body, options: [])
    }
    
    if let string = body as? String {
        return NSData(base64EncodedString: string, options: [])
    }
    
    return nil
}
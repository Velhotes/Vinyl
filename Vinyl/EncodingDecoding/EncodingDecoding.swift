//
//  EncodingDecoding.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

// Heavily inspired by Venmo's work on DVR (https://github.com/venmo/DVR).
func encodeBody(bodyData: NSData?, headers: HTTPHeaders) -> AnyObject? {
    
    guard
        let body = bodyData,
        let contentType = headers["Content-Type"]
        else {
            return nil
    }
    
    switch contentType {
        
    case _ where contentType.hasPrefix("text/"):
        return NSString(data: body, encoding: NSUTF8StringEncoding).map (String.init)
        
    case _ where contentType.hasPrefix("application/json"):
        return try? NSJSONSerialization.JSONObjectWithData(body, options: [])
        
    default:
        return body.base64EncodedStringWithOptions([])
    }
}

func decodeBody(bodyData: AnyObject?, headers: HTTPHeaders) -> NSData? {
    
    guard let body = bodyData else { return nil }
    
    guard let contentType = headers["Content-Type"]  else {
        
        // As last resource, we will check if the bodyData is a string and if so convert it
        if let string = body as? String {
            return string.dataUsingEncoding(NSUTF8StringEncoding)
        }
        else {
            return nil
        }
    }
    
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

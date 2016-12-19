//
//  EncodingDecoding.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

// Heavily inspired by Venmo's work on DVR (https://github.com/venmo/DVR).
func encodeBody(_ bodyData: Data?, headers: HTTPHeaders) -> AnyObject? {
    
    guard
        let body = bodyData,
        let contentType = headers["Content-Type"]
        else {
            return nil
    }
    
    switch contentType {
        
    case _ where contentType.hasPrefix("text/"):
        return String(data: body, encoding: .utf8) as AnyObject?
        
    case _ where contentType.hasPrefix("application/json"):
        return try! JSONSerialization.jsonObject(with: body, options: []) as AnyObject?
        
    default:
        return body.base64EncodedString(options: []) as AnyObject?
    }
}

func decodeBody(_ bodyData: Any?, headers: HTTPHeaders) -> Data? {
    
    guard let body = bodyData else { return nil }
    
    guard let contentType = headers["Content-Type"]  else {
        
        // As last resource, we will check if the bodyData is a string and if so convert it
        if let string = body as? String {
            return string.data(using: .utf8)
        }
        else {
            return nil
        }
    }
    
    if let string = body as? String, contentType.hasPrefix("text/") {
        return string.data(using: .utf8)
    }
    
    if contentType.hasPrefix("application/json") {
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    if let string = body as? String {
        return Data(base64Encoded: string, options: [])
    }
    
    return nil
}

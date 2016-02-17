//
//  HTTPURLResponse.swift
//  Vinyl
//
//  Created by Rui Peres on 17/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

// Idea taken from VENMO/DVR
class HTTPURLResponse: NSHTTPURLResponse {
    
    private var _statusCode: Int?
    override var statusCode: Int {
        get {
            return _statusCode ?? super.statusCode
        }
        
        set {
            _statusCode = newValue
        }
    }
    
    private var _allHeaderFields: [NSObject : AnyObject]?
    override var allHeaderFields: [NSObject : AnyObject] {
        get {
            return _allHeaderFields ?? super.allHeaderFields
        }
        
        set {
            _allHeaderFields = newValue
        }
    }
}

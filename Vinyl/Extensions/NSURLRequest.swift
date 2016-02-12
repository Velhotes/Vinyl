//
//  NSURLRequest.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

extension NSURLRequest {
 
    func toSong() -> Song {
        
        guard let url = URL?.absoluteString else { fatalError("request: (\request) is missing the url 😩") }
        
        let headers = allHTTPHeaderFields ?? [:]
        let body = encodeBody(HTTPBody, headers: headers)
        
        return Song(url: url, body: body, HTTPHeaders: headers)
    }
}